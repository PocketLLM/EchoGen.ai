from __future__ import annotations

from typing import Any, Dict, List

from unittest.mock import AsyncMock

import httpx
import pytest
from fastapi import HTTPException, status

from backend.app.schemas.apikey import APIKeyCreate, APIKeyUpdate
from backend.app.services.api_key_service import APIKeyService, USER_API_KEYS_TABLE


class FakeSupabaseClient:
    def __init__(self) -> None:
        self.insert = AsyncMock()
        self.select = AsyncMock()
        self.update = AsyncMock()
        self.delete = AsyncMock()


def build_db_record(**overrides: Any) -> Dict[str, Any]:
    base: Dict[str, Any] = {
        "id": "key-123",
        "user_id": "user-1",
        "provider": "openai",
        "key_alias": "Primary",
        "metadata": {"status": "valid"},
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z",
    }
    base.update(overrides)
    return base


def make_http_status_error(status_code: int, payload: Dict[str, Any]) -> httpx.HTTPStatusError:
    request = httpx.Request("POST", "https://example.supabase.co/rest/v1/user_api_keys")
    response = httpx.Response(status_code, json=payload, request=request)
    return httpx.HTTPStatusError("error", request=request, response=response)


@pytest.mark.anyio
async def test_create_api_key_persists_and_returns_record() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    payload = APIKeyCreate(provider="openai", key_alias="Primary", encrypted_key="cipher", metadata={"status": "valid"})
    db_response: List[Dict[str, Any]] = [build_db_record()]
    client.insert.return_value = db_response

    result = await service.create_api_key("user-1", payload)

    client.insert.assert_awaited_once_with(
        USER_API_KEYS_TABLE,
        {
            "user_id": "user-1",
            "provider": "openai",
            "key_alias": "Primary",
            "encrypted_key": "cipher",
            "metadata": {"status": "valid"},
        },
    )
    assert result.id == "key-123"
    assert result.provider == "openai"
    assert result.metadata == {"status": "valid"}


@pytest.mark.anyio
async def test_create_api_key_surfaces_supabase_error() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    payload = APIKeyCreate(provider="openai", key_alias=None, encrypted_key="cipher", metadata={})
    client.insert.side_effect = make_http_status_error(status.HTTP_409_CONFLICT, {"message": "duplicate"})

    with pytest.raises(HTTPException) as exc:
        await service.create_api_key("user-1", payload)

    assert exc.value.status_code == status.HTTP_409_CONFLICT
    assert exc.value.detail == "duplicate"


@pytest.mark.anyio
async def test_create_api_key_handles_transport_error() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    payload = APIKeyCreate(provider="openai", key_alias=None, encrypted_key="cipher", metadata={})
    client.insert.side_effect = httpx.TransportError("boom")

    with pytest.raises(HTTPException) as exc:
        await service.create_api_key("user-1", payload)

    assert exc.value.status_code == status.HTTP_502_BAD_GATEWAY
    assert exc.value.detail == "Failed to save API key"


@pytest.mark.anyio
async def test_create_api_key_with_empty_response_raises_gateway_error() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    payload = APIKeyCreate(provider="openai", key_alias=None, encrypted_key="cipher", metadata={})
    client.insert.return_value = []

    with pytest.raises(HTTPException) as exc:
        await service.create_api_key("user-1", payload)

    assert exc.value.status_code == status.HTTP_502_BAD_GATEWAY
    assert "Unable to persist API key" in exc.value.detail


@pytest.mark.anyio
async def test_list_api_keys_returns_parsed_models() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    client.select.return_value = [build_db_record(), build_db_record(id="key-456", provider="gemini")]

    results = await service.list_api_keys("user-1")

    client.select.assert_awaited_once_with(USER_API_KEYS_TABLE, filters={"user_id": "eq.user-1"})
    assert [item.id for item in results] == ["key-123", "key-456"]


@pytest.mark.anyio
async def test_list_api_keys_surfaces_http_error() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    client.select.side_effect = make_http_status_error(status.HTTP_500_INTERNAL_SERVER_ERROR, {"message": "broken"})

    with pytest.raises(HTTPException) as exc:
        await service.list_api_keys("user-1")

    assert exc.value.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
    assert exc.value.detail == "broken"


@pytest.mark.anyio
async def test_update_api_key_requires_payload() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    with pytest.raises(HTTPException) as exc:
        await service.update_api_key("user-1", "key-123", APIKeyUpdate())

    assert exc.value.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.anyio
async def test_update_api_key_returns_updated_record() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    client.update.return_value = [build_db_record(key_alias="Updated")]

    result = await service.update_api_key("user-1", "key-123", APIKeyUpdate(key_alias="Updated"))

    client.update.assert_awaited_once_with(
        USER_API_KEYS_TABLE,
        {"key_alias": "Updated"},
        filters={"id": "eq.key-123", "user_id": "eq.user-1"},
    )
    assert result.key_alias == "Updated"


@pytest.mark.anyio
async def test_update_api_key_not_found() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    client.update.return_value = []

    with pytest.raises(HTTPException) as exc:
        await service.update_api_key("user-1", "key-123", APIKeyUpdate(key_alias="Updated"))

    assert exc.value.status_code == status.HTTP_404_NOT_FOUND


@pytest.mark.anyio
async def test_delete_api_key_invokes_supabase() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    await service.delete_api_key("user-1", "key-123")

    client.delete.assert_awaited_once_with(
        USER_API_KEYS_TABLE,
        filters={"id": "eq.key-123", "user_id": "eq.user-1"},
    )


@pytest.mark.anyio
async def test_delete_api_key_surfaces_error() -> None:
    client = FakeSupabaseClient()
    service = APIKeyService(client)

    client.delete.side_effect = make_http_status_error(status.HTTP_400_BAD_REQUEST, {"message": "bad"})

    with pytest.raises(HTTPException) as exc:
        await service.delete_api_key("user-1", "key-123")

    assert exc.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc.value.detail == "bad"
