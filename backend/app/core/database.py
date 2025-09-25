"""Supabase client utilities used by the service layer."""
from __future__ import annotations

import asyncio
from asyncio import AbstractEventLoop
from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Optional

import httpx

from .config import Settings, get_settings


@dataclass
class SupabaseRequestOptions:
    """Options that control Supabase REST requests."""

    count: Optional[str] = None
    prefer: Optional[str] = None


class SupabaseAsyncClient:
    """Minimal asynchronous Supabase REST client."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._rest_client = httpx.AsyncClient(
            base_url=settings.supabase_rest_url,
            headers={
                "apikey": settings.supabase_service_role_key,
                "Authorization": f"Bearer {settings.supabase_service_role_key}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
            timeout=30.0,
        )
        self._auth_client = httpx.AsyncClient(
            base_url=settings.supabase_auth_url,
            headers={
                "apikey": settings.supabase_anon_key,
                "Authorization": f"Bearer {settings.supabase_anon_key}",
                "Content-Type": "application/json",
            },
            timeout=30.0,
        )
        self._storage_client = httpx.AsyncClient(
            base_url=settings.supabase_storage_url,
            headers={
                "apikey": settings.supabase_service_role_key,
                "Authorization": f"Bearer {settings.supabase_service_role_key}",
            },
            timeout=30.0,
        )

    @property
    def rest(self) -> httpx.AsyncClient:
        return self._rest_client

    @property
    def auth(self) -> httpx.AsyncClient:
        return self._auth_client

    @property
    def storage(self) -> httpx.AsyncClient:
        return self._storage_client

    async def close(self) -> None:
        await self._rest_client.aclose()
        await self._auth_client.aclose()
        await self._storage_client.aclose()

    async def select(
        self,
        table: str,
        *,
        columns: str = "*",
        filters: Optional[Dict[str, str]] = None,
        order: Optional[str] = None,
        limit: Optional[int] = None,
        offset: Optional[int] = None,
        options: Optional[SupabaseRequestOptions] = None,
    ) -> List[Dict[str, Any]]:
        params: Dict[str, Any] = {"select": columns}
        if filters:
            params.update(filters)
        if order:
            params["order"] = order
        if limit is not None:
            params["limit"] = str(limit)
        if offset is not None:
            params["offset"] = str(offset)
        if options and options.count:
            params["count"] = options.count

        headers = {}
        if options and options.prefer:
            headers["Prefer"] = options.prefer

        response = await self._rest_client.get(f"/{table}", params=params, headers=headers)
        response.raise_for_status()
        return response.json()

    async def insert(
        self,
        table: str,
        payload: Dict[str, Any] | Iterable[Dict[str, Any]],
        *,
        options: Optional[SupabaseRequestOptions] = None,
    ) -> List[Dict[str, Any]]:
        headers = {"Prefer": "return=representation"}
        if options and options.prefer:
            headers["Prefer"] = options.prefer

        response = await self._rest_client.post(f"/{table}", json=payload, headers=headers)
        response.raise_for_status()
        if not response.content:
            return []
        return response.json()

    async def update(
        self,
        table: str,
        payload: Dict[str, Any],
        *,
        filters: Optional[Dict[str, str]] = None,
        options: Optional[SupabaseRequestOptions] = None,
    ) -> List[Dict[str, Any]]:
        headers = {}
        if options and options.prefer:
            headers["Prefer"] = options.prefer

        response = await self._rest_client.patch(
            f"/{table}", params=filters or {}, json=payload, headers=headers
        )
        response.raise_for_status()
        if not response.content:
            return []
        return response.json()

    async def delete(
        self,
        table: str,
        *,
        filters: Optional[Dict[str, str]] = None,
    ) -> List[Dict[str, Any]]:
        response = await self._rest_client.delete(f"/{table}", params=filters or {})
        response.raise_for_status()
        if not response.content:
            return []
        return response.json()

    async def rpc(self, function: str, *, payload: Optional[Dict[str, Any]] = None) -> Any:
        response = await self._rest_client.post(f"/rpc/{function}", json=payload or {})
        response.raise_for_status()
        return response.json()


_client: Optional[SupabaseAsyncClient] = None
_client_loop: Optional[AbstractEventLoop] = None


def _get_event_loop() -> Optional[AbstractEventLoop]:
    """Return the currently active event loop if available."""

    try:
        return asyncio.get_running_loop()
    except RuntimeError:
        try:
            return asyncio.get_event_loop()
        except RuntimeError:
            return None


def get_supabase_client(settings: Optional[Settings] = None) -> SupabaseAsyncClient:
    global _client
    global _client_loop

    loop = _get_event_loop()
    if _client is None:
        _client = SupabaseAsyncClient(settings or get_settings())
        _client_loop = loop
        return _client

    # Recreate the client if the previous event loop is no longer usable.
    recreate_client = False
    if _client_loop is None and loop is not None:
        recreate_client = True
    elif _client_loop is not None:
        if _client_loop.is_closed():
            recreate_client = True
        elif loop is not None and loop is not _client_loop:
            recreate_client = True

    if recreate_client:
        _client = SupabaseAsyncClient(settings or get_settings())
        _client_loop = loop

    return _client
