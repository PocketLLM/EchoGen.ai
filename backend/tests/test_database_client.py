"""Tests for the lightweight Supabase client wrapper."""
from __future__ import annotations

from unittest.mock import AsyncMock

import httpx
import pytest

from backend.app.core.config import Settings
from backend.app.core.database import SupabaseAsyncClient


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
