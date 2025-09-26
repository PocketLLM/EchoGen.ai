from datetime import UTC, datetime, timedelta
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi import HTTPException, status
import httpx

from backend.app.core.config import Settings
from backend.app.schemas.auth import (
    AuthMethod,
    OnboardingAnswer,
    OnboardingSubmission,
    ProfileUpdateRequest,
    SignInRequest,
    SignUpRequest,
    UserProfile,
)
from backend.app.services import auth_service
from backend.app.services.auth_service import AuthService


class MockResponse:
    def __init__(self, payload, status_code: int = 200) -> None:
        self._payload = payload
        self.status_code = status_code

    def json(self):
        return self._payload

    def raise_for_status(self) -> None:
        if self.status_code >= 400:
            raise RuntimeError(f"HTTP {self.status_code}")


class FakeSupabaseClient:
    def __init__(self) -> None:
        self.auth = MagicMock()
        self.auth.post = AsyncMock()
        self.auth.get = AsyncMock()
        self.rest = MagicMock()
        self.rest.get = AsyncMock()
        self.select = AsyncMock()
        self.insert = AsyncMock()
        self.update = AsyncMock()


@pytest.fixture()
def settings() -> Settings:
    return Settings(
        supabase_url="https://example.supabase.co",
        supabase_anon_key="anon_test_key",
        supabase_service_role_key="service_test_key",
        jwt_secret="secret",
    )


@pytest.fixture()
def fake_client() -> FakeSupabaseClient:
    return FakeSupabaseClient()


@pytest.mark.anyio
async def test_sign_up_rejects_non_supported_method(
    fake_client: FakeSupabaseClient, settings: Settings
) -> None:
    service = AuthService(fake_client, settings)

    payload = SignUpRequest(method=AuthMethod.GOOGLE, email=None, password=None)

    with pytest.raises(HTTPException) as exc:
        await service.sign_up(payload)

    assert exc.value.status_code == status.HTTP_501_NOT_IMPLEMENTED
    fake_client.auth.post.assert_not_awaited()


@pytest.mark.anyio
async def test_sign_in_rejects_non_supported_method(
    fake_client: FakeSupabaseClient, settings: Settings
) -> None:
    service = AuthService(fake_client, settings)

    payload = SignInRequest(method=AuthMethod.GOOGLE, email=None, password=None)

    with pytest.raises(HTTPException) as exc:
        await service.sign_in(payload)

    assert exc.value.status_code == status.HTTP_501_NOT_IMPLEMENTED
    fake_client.auth.post.assert_not_awaited()


@pytest.mark.anyio
async def test_sign_up_with_phone_uses_phone_payload(
    fake_client: FakeSupabaseClient, settings: Settings
) -> None:
    service = AuthService(fake_client, settings)
    service._ensure_profile_row = AsyncMock(return_value={})  # type: ignore[attr-defined]
    auth_response = MagicMock()
    service._build_auth_response = AsyncMock(return_value=auth_response)  # type: ignore[attr-defined]

    response_payload = {"user": {"id": "user-1"}, "session": {"access_token": "jwt"}}
    fake_client.auth.post = AsyncMock(return_value=MockResponse(response_payload))

    payload = SignUpRequest(method=AuthMethod.PHONE, phoneNumber="+13334445555", password="Passw0rd!")

    result = await service.sign_up(payload)

    fake_client.auth.post.assert_awaited_once()
    request_json = fake_client.auth.post.await_args.kwargs["json"]
    assert request_json["phone"] == "+13334445555"
    assert request_json["password"] == "Passw0rd!"
    assert result is auth_response


@pytest.mark.anyio
async def test_sign_in_with_phone_uses_password_grant(
    fake_client: FakeSupabaseClient, settings: Settings
) -> None:
    service = AuthService(fake_client, settings)
    auth_response = MagicMock()
    auth_response.user.id = "user-1"
    service._build_auth_response = AsyncMock(return_value=auth_response)  # type: ignore[attr-defined]
    service.cancel_pending_deletion = AsyncMock(return_value=None)  # type: ignore[attr-defined]

    response_payload = {"user": {"id": "user-1"}, "session": {"access_token": "jwt"}}
    fake_client.auth.post = AsyncMock(return_value=MockResponse(response_payload))

    payload = SignInRequest(
        method=AuthMethod.PHONE,
        phoneNumber="+13334445555",
        password="Passw0rd!",
    )

    result = await service.sign_in(payload)

    fake_client.auth.post.assert_awaited_once()
    request_json = fake_client.auth.post.await_args.kwargs["json"]
    assert request_json["phone"] == "+13334445555"
    assert request_json["password"] == "Passw0rd!"
    service.cancel_pending_deletion.assert_awaited_once_with("user-1")
    assert result is auth_response


@pytest.mark.anyio
async def test_schedule_account_deletion_creates_request(
    fake_client: FakeSupabaseClient, settings: Settings, monkeypatch: pytest.MonkeyPatch
) -> None:
    service = AuthService(fake_client, settings)

    fixed_now = datetime(2024, 1, 1, tzinfo=UTC)

    class FrozenDateTime(datetime):
        @classmethod
        def now(cls, tz=None):  # type: ignore[override]
            if tz is None:
                return fixed_now.replace(tzinfo=None)
            return fixed_now.astimezone(tz)

    monkeypatch.setattr(auth_service, "datetime", FrozenDateTime)

    scheduled_for = fixed_now + timedelta(days=30)
    record = {
        "scheduled_for": scheduled_for.isoformat(),
        "requested_at": fixed_now.isoformat(),
        "cancelled_at": None,
        "completed_at": None,
    }

    fake_client.select = AsyncMock(side_effect=[[], [record]])
    fake_client.insert = AsyncMock(return_value=[record])

    status_response = await service.schedule_account_deletion("user-123")

    assert status_response.scheduled_for == scheduled_for
    assert status_response.requested_at == fixed_now
    fake_client.insert.assert_awaited_once()


@pytest.mark.anyio
async def test_cancel_account_deletion_no_active_request(
    fake_client: FakeSupabaseClient, settings: Settings
) -> None:
    service = AuthService(fake_client, settings)

    fake_client.select = AsyncMock(return_value=[])

    result = await service.cancel_pending_deletion("user-123")

    assert result is None
    fake_client.update.assert_not_called()


@pytest.mark.anyio
async def test_update_profile_updates_requested_fields(
    fake_client: FakeSupabaseClient, settings: Settings
) -> None:
    service = AuthService(fake_client, settings)

    expected_user = UserProfile(
        id="user-1",
        email="user@example.com",
        full_name="Echo Creator",
        created_at=datetime(2024, 1, 1, tzinfo=UTC),
        onboarding_completed=True,
    )

    fake_client.update = AsyncMock()
    service._fetch_auth_user = AsyncMock(  # type: ignore[attr-defined]
        return_value={
            "id": "user-1",
            "email": "user@example.com",
            "created_at": datetime(2024, 1, 1, tzinfo=UTC).isoformat(),
        }
    )
    service._build_user_profile = AsyncMock(return_value=expected_user)  # type: ignore[attr-defined]

    payload = ProfileUpdateRequest(fullName="Echo Creator", bio="Podcaster", preferences={"theme": "light"})

    result = await service.update_profile("user-1", payload)

    await_call = fake_client.update.await_args
    assert await_call.args[0] == "profiles"
    update_payload = await_call.args[1]
    assert update_payload["full_name"] == "Echo Creator"
    assert update_payload["bio"] == "Podcaster"
    assert "updated_at" in update_payload
    assert await_call.kwargs["filters"] == {"id": "eq.user-1"}

    assert result == expected_user


@pytest.mark.anyio
async def test_submit_onboarding_persists_answers(
    fake_client: FakeSupabaseClient, settings: Settings
) -> None:
    service = AuthService(fake_client, settings)

    expected_user = UserProfile(
        id="user-1",
        email="user@example.com",
        full_name="Echo Creator",
        created_at=datetime(2024, 1, 1, tzinfo=UTC),
        onboarding_completed=True,
    )

    fake_client.select = AsyncMock(return_value=[{"preferences": {"existing": "value"}}])
    fake_client.insert = AsyncMock(return_value=[])
    fake_client.update = AsyncMock(return_value=[])
    service._fetch_auth_user = AsyncMock(  # type: ignore[attr-defined]
        return_value={
            "id": "user-1",
            "email": "user@example.com",
            "created_at": datetime(2024, 1, 1, tzinfo=UTC).isoformat(),
        }
    )
    service._build_user_profile = AsyncMock(return_value=expected_user)  # type: ignore[attr-defined]

    submission = OnboardingSubmission(
        responses=[
            OnboardingAnswer(question_id="format", question="Preferred format", answer="Interview"),
            OnboardingAnswer(
                question_id="cadence",
                question="Publishing cadence",
                answer={"option": "Weekly"},
            ),
        ],
        completed_at=datetime(2024, 1, 2, tzinfo=UTC),
    )

    result = await service.submit_onboarding("user-1", submission)

    insert_call = fake_client.insert.await_args
    assert insert_call.args[0] == "onboarding_responses"
    inserted_payload = insert_call.args[1]
    assert inserted_payload["user_id"] == "user-1"
    assert inserted_payload["responses"][0]["questionId"] == "format"
    assert inserted_payload["responses"][1]["answer"] == {"option": "Weekly"}

    update_call = fake_client.update.await_args
    assert update_call.args[0] == "profiles"
    update_payload = update_call.args[1]
    assert update_payload["onboarding_completed"] is True
    assert update_payload["preferences"]["existing"] == "value"
    onboarding_preferences = update_payload["preferences"]["onboarding"]
    assert onboarding_preferences["responses"][0]["questionId"] == "format"
    assert onboarding_preferences["responses"][1]["answer"] == {"option": "Weekly"}
    assert "completedAt" in onboarding_preferences
    assert update_call.kwargs["filters"] == {"id": "eq.user-1"}

    assert result == expected_user


@pytest.mark.anyio
async def test_submit_onboarding_logs_insert_failure(
    fake_client: FakeSupabaseClient, settings: Settings
) -> None:
    service = AuthService(fake_client, settings)

    expected_user = UserProfile(
        id="user-1",
        email="user@example.com",
        full_name="Echo Creator",
        created_at=datetime(2024, 1, 1, tzinfo=UTC),
        onboarding_completed=True,
    )

    fake_client.select = AsyncMock(return_value=[{"preferences": {}}])
    request = httpx.Request(
        "POST",
        "https://example.supabase.co/rest/v1/onboarding_responses",
    )
    response = httpx.Response(500, request=request)
    fake_client.insert = AsyncMock(
        side_effect=httpx.HTTPStatusError("boom", request=request, response=response)
    )
    fake_client.update = AsyncMock(return_value=[])
    service._fetch_auth_user = AsyncMock(  # type: ignore[attr-defined]
        return_value={
            "id": "user-1",
            "email": "user@example.com",
            "created_at": datetime(2024, 1, 1, tzinfo=UTC).isoformat(),
        }
    )
    service._build_user_profile = AsyncMock(return_value=expected_user)  # type: ignore[attr-defined]

    submission = OnboardingSubmission(
        responses=[
            OnboardingAnswer(question_id="format", question="Preferred format", answer="Interview"),
        ],
        completed_at=datetime(2024, 1, 2, tzinfo=UTC),
    )

    result = await service.submit_onboarding("user-1", submission)

    fake_client.insert.assert_awaited_once()
    update_payload = fake_client.update.await_args.args[1]
    assert "onboarding" in update_payload["preferences"]
    assert update_payload["preferences"]["onboarding"]["responses"][0]["questionId"] == "format"
    assert result == expected_user
