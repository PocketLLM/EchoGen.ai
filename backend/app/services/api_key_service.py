"""Service for securely storing provider API keys."""
from __future__ import annotations

from typing import List

from fastapi import HTTPException, status

from ..core.database import SupabaseAsyncClient
from ..schemas.apikey import APIKeyCreate, APIKeyResponse, APIKeyUpdate

USER_API_KEYS_TABLE = "user_api_keys"


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
        response = await self._client.insert(USER_API_KEYS_TABLE, record)
        return self._parse(response)[0]

    async def list_api_keys(self, user_id: str) -> List[APIKeyResponse]:
        response = await self._client.select(USER_API_KEYS_TABLE, filters={"user_id": f"eq.{user_id}"})
        return self._parse(response)

    async def update_api_key(self, user_id: str, key_id: str, payload: APIKeyUpdate) -> APIKeyResponse:
        response = await self._client.update(
            USER_API_KEYS_TABLE,
            payload.model_dump(exclude_none=True),
            filters={"id": f"eq.{key_id}", "user_id": f"eq.{user_id}"},
        )
        parsed = self._parse(response)
        if not parsed:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="API key not found")
        return parsed[0]

    async def delete_api_key(self, user_id: str, key_id: str) -> None:
        await self._client.delete(USER_API_KEYS_TABLE, filters={"id": f"eq.{key_id}", "user_id": f"eq.{user_id}"})

    def _parse(self, data) -> List[APIKeyResponse]:
        return [APIKeyResponse(**item) for item in data]
