"""Tests for the lightweight Supabase client wrapper."""
from __future__ import annotations

import asyncio
from unittest.mock import AsyncMock

import httpx
import pytest

from backend.app.core.config import Settings
from backend.app.core.database import SupabaseAsyncClient, get_supabase_client


@pytest.fixture()
def settings() -> Settings:
    return Settings(
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon-test",
        supabase_service_role_key="service-test",
        jwt_secret="secret",
    )


@pytest.mark.anyio
async def test_update_handles_no_content(settings: Settings) -> None:
    client = SupabaseAsyncClient(settings)
    try:
        response = httpx.Response(
            204, request=httpx.Request("PATCH", "https://example.supabase.co/rest/v1/profiles")
        )
        client._rest_client.patch = AsyncMock(return_value=response)  # type: ignore[attr-defined]

        result = await client.update("profiles", {"full_name": "Test"})

        assert result == []
    finally:
        await client.close()


@pytest.mark.anyio
async def test_insert_handles_empty_payload(settings: Settings) -> None:
    client = SupabaseAsyncClient(settings)
    try:
        response = httpx.Response(
            201, request=httpx.Request("POST", "https://example.supabase.co/rest/v1/onboarding_responses")
        )
        client._rest_client.post = AsyncMock(return_value=response)  # type: ignore[attr-defined]

        result = await client.insert("onboarding_responses", {"user_id": "123"})

        assert result == []
    finally:
        await client.close()


@pytest.mark.anyio
async def test_delete_handles_no_content(settings: Settings) -> None:
    client = SupabaseAsyncClient(settings)
    try:
        response = httpx.Response(
            204, request=httpx.Request("DELETE", "https://example.supabase.co/rest/v1/profiles")
        )
        client._rest_client.delete = AsyncMock(return_value=response)  # type: ignore[attr-defined]

        result = await client.delete("profiles", filters={"id": "eq.123"})

        assert result == []
    finally:
        await client.close()


@pytest.mark.anyio
async def test_get_supabase_client_reuses_active_loop(settings: Settings) -> None:
    from backend.app.core import database

    database._client = None
    database._client_loop = None

    client_one = get_supabase_client(settings)
    client_two = get_supabase_client(settings)

    assert client_one is client_two

    await client_one.close()
    database._client = None
    database._client_loop = None


def test_get_supabase_client_recreates_for_new_loop(settings: Settings) -> None:
    from backend.app.core import database

    database._client = None
    database._client_loop = None

    async def obtain_client() -> SupabaseAsyncClient:
        return get_supabase_client(settings)

    loop_one = asyncio.new_event_loop()
    try:
        asyncio.set_event_loop(loop_one)
        client_one = loop_one.run_until_complete(obtain_client())
        original_close = client_one.close
        close_mock = AsyncMock(side_effect=original_close)
        client_one.close = close_mock  # type: ignore[method-assign]
    finally:
        asyncio.set_event_loop(None)
        loop_one.close()

    loop_two = asyncio.new_event_loop()
    try:
        asyncio.set_event_loop(loop_two)
        client_two = loop_two.run_until_complete(obtain_client())
        assert client_two is not client_one
        loop_two.run_until_complete(asyncio.sleep(0))
        close_mock.assert_awaited_once()
        loop_two.run_until_complete(client_two.close())
    finally:
        asyncio.set_event_loop(None)
        loop_two.close()

    database._client = None
    database._client_loop = None
