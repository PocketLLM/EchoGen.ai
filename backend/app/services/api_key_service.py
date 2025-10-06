"""Service for securely storing provider API keys."""
from __future__ import annotations

import logging
from typing import Any, Dict, Iterable, List, Optional

import httpx
from fastapi import HTTPException, status

from ..core.database import SupabaseAsyncClient
from ..schemas.apikey import APIKeyCreate, APIKeyResponse, APIKeyUpdate

USER_API_KEYS_TABLE = "user_api_keys"

logger = logging.getLogger(__name__)


class APIKeyService:
    def __init__(self, client: SupabaseAsyncClient) -> None:
        self._client = client

    async def create_api_key(self, user_id: str, payload: APIKeyCreate) -> APIKeyResponse:
        record = {
            "user_id": user_id,
            "provider": payload.provider,
            "key_alias": payload.key_alias,
            "encrypted_key": payload.encrypted_key,
            "metadata": payload.metadata,
        }
        try:
            response = await self._client.insert(USER_API_KEYS_TABLE, record)
        except httpx.HTTPError as exc:  # pragma: no cover - exercised via helper
            self._handle_http_error(exc, "Failed to save API key")

        parsed = self._parse(response)
        if not parsed:
            logger.error(
                "Supabase insert returned empty payload for API key",
                extra={"user_id": user_id, "provider": payload.provider},
            )
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="Unable to persist API key. Please try again.",
            )
        return parsed[0]

    async def list_api_keys(self, user_id: str) -> List[APIKeyResponse]:
        try:
            response = await self._client.select(
                USER_API_KEYS_TABLE, filters={"user_id": f"eq.{user_id}"}
            )
        except httpx.HTTPError as exc:  # pragma: no cover - exercised via helper
            self._handle_http_error(exc, "Failed to load API keys")
        return self._parse(response)

    async def update_api_key(self, user_id: str, key_id: str, payload: APIKeyUpdate) -> APIKeyResponse:
        update_payload = payload.model_dump(exclude_none=True)
        if not update_payload:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No fields provided for update",
            )

        try:
            response = await self._client.update(
                USER_API_KEYS_TABLE,
                update_payload,
                filters={"id": f"eq.{key_id}", "user_id": f"eq.{user_id}"},
            )
        except httpx.HTTPError as exc:  # pragma: no cover - exercised via helper
            self._handle_http_error(exc, "Failed to update API key")

        parsed = self._parse(response)
        if not parsed:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="API key not found")
        return parsed[0]

    async def delete_api_key(self, user_id: str, key_id: str) -> None:
        try:
            await self._client.delete(
                USER_API_KEYS_TABLE, filters={"id": f"eq.{key_id}", "user_id": f"eq.{user_id}"}
            )
        except httpx.HTTPError as exc:  # pragma: no cover - exercised via helper
            self._handle_http_error(exc, "Failed to delete API key")

    def _parse(self, data: Optional[Iterable[Dict[str, Any]]]) -> List[APIKeyResponse]:
        records: List[APIKeyResponse] = []
        if not data:
            return records

        for item in data:
            try:
                record = {
                    "id": item["id"],
                    "provider": item["provider"],
                    "key_alias": item.get("key_alias"),
                    "metadata": item.get("metadata") or {},
                    "created_at": item["created_at"],
                    "updated_at": item["updated_at"],
                }
            except KeyError as exc:  # pragma: no cover - defensive guard
                logger.warning(
                    "Incomplete API key record received",
                    extra={"record": item},
                    exc_info=True,
                )
                continue
            records.append(APIKeyResponse(**record))
        return records

    def _handle_http_error(self, exc: httpx.HTTPError, fallback_detail: str) -> None:
        if isinstance(exc, httpx.HTTPStatusError):
            detail = self._extract_error_detail(exc.response) or fallback_detail
            raise HTTPException(status_code=exc.response.status_code, detail=detail) from exc

        logger.error("Supabase request failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=fallback_detail,
        ) from exc

    @staticmethod
    def _extract_error_detail(response: httpx.Response) -> Optional[str]:
        try:
            payload = response.json()
        except ValueError:  # pragma: no cover - non JSON payloads are rare
            text = response.text.strip()
            return text or None

        if isinstance(payload, dict):
            candidates: List[Any] = [
                payload.get("detail"),
                payload.get("message"),
                payload.get("msg"),
                payload.get("error_description"),
                payload.get("error"),
            ]
            for candidate in candidates:
                if isinstance(candidate, str) and candidate:
                    return candidate
                if isinstance(candidate, dict):
                    nested = candidate.get("message")
                    if isinstance(nested, str) and nested:
                        return nested

        return None
