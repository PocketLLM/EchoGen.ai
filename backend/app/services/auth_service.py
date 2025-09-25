"""Service for interacting with Supabase Auth."""
from __future__ import annotations

import json
from datetime import UTC, datetime, timedelta
from typing import Any, Dict, Optional

import httpx
from fastapi import HTTPException, status

from ..core.config import Settings
from ..core.database import SupabaseAsyncClient
from ..core.logging import get_logger
from ..schemas.auth import (
    AccountDeletionStatus,
    AuthMethod,
    AuthResponse,
    OnboardingSubmission,
    ProfileUpdateRequest,
    SessionTokens,
    SignInRequest,
    SignUpRequest,
    UserProfile,
    VerifyTokenResponse,
)


logger = get_logger(__name__)


class AuthService:
    """Wrapper around Supabase Auth REST endpoints."""

    def __init__(self, client: SupabaseAsyncClient, settings: Settings) -> None:
        self._client = client
        self._settings = settings

    async def sign_up(self, payload: SignUpRequest) -> AuthResponse:
        metadata: Dict[str, Any] = {}
        if payload.full_name:
            metadata["full_name"] = payload.full_name

        request_body: Dict[str, Any] = {
            "password": payload.password,
        }
        if payload.method is AuthMethod.EMAIL:
            request_body["email"] = payload.email
        elif payload.method is AuthMethod.PHONE:
            request_body["phone"] = payload.phone_number
        else:
            raise HTTPException(
                status_code=status.HTTP_501_NOT_IMPLEMENTED,
                detail="Selected sign-up method will be available soon",
            )
        if metadata:
            request_body["data"] = metadata

        response = await self._client.auth.post("/signup", json=request_body)
        response.raise_for_status()
        data = response.json()

        user = data.get("user", data)
        await self._ensure_profile_row(user["id"], payload.full_name)
        return await self._build_auth_response(data)

    async def sign_in(self, payload: SignInRequest) -> AuthResponse:
        if payload.method is AuthMethod.EMAIL:
            credentials = {"email": payload.email, "password": payload.password}
        elif payload.method is AuthMethod.PHONE:
            credentials = {"phone": payload.phone_number, "password": payload.password}
        else:
            raise HTTPException(
                status_code=status.HTTP_501_NOT_IMPLEMENTED,
                detail="Selected sign-in method will be available soon",
            )

        response = await self._client.auth.post("/token?grant_type=password", json=credentials)
        if response.status_code == status.HTTP_400_BAD_REQUEST:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        response.raise_for_status()
        data = response.json()

        auth_response = await self._build_auth_response(data)
        await self.cancel_pending_deletion(auth_response.user.id)
        return auth_response

    async def verify_access_token(self, token: str) -> VerifyTokenResponse:
        response = await self._client.auth.get(
            "/user",
            headers={
                "Authorization": f"Bearer {token}",
                "apikey": self._settings.supabase_anon_key,
            },
        )
        if response.status_code == status.HTTP_401_UNAUTHORIZED:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token")
        response.raise_for_status()
        data = response.json()
        user = await self._build_user_profile(data.get("user", data))
        return VerifyTokenResponse(user=user)

    async def get_user_by_id(self, user_id: str) -> UserProfile:
        """Fetch the latest profile details for the given user identifier."""

        auth_user = await self._fetch_auth_user(user_id)
        return await self._build_user_profile(auth_user)

    async def update_profile(self, user_id: str, updates: ProfileUpdateRequest) -> UserProfile:
        payload: Dict[str, Any] = {"updated_at": datetime.now(UTC).isoformat()}
        if updates.full_name is not None:
            payload["full_name"] = updates.full_name
        if updates.avatar_url is not None:
            payload["avatar_url"] = str(updates.avatar_url)
        if updates.bio is not None:
            payload["bio"] = updates.bio
        if updates.preferences is not None:
            payload["preferences"] = updates.preferences

        if len(payload) == 1:
            # Nothing to update beyond timestamp
            existing = await self._fetch_profile_row(user_id)
            if not existing:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")
        else:
            await self._client.update(
                "profiles",
                payload,
                filters={
                    "id": f"eq.{user_id}",
                },
            )

        auth_user = await self._fetch_auth_user(user_id)
        return await self._build_user_profile(auth_user)

    async def submit_onboarding(self, user_id: str, submission: OnboardingSubmission) -> UserProfile:
        completed_at = submission.completed_at
        if completed_at.tzinfo is None:
            completed_at = completed_at.replace(tzinfo=UTC)
        completed_at_utc = completed_at.astimezone(UTC)

        responses_payload = [
            response.model_dump(by_alias=True) for response in submission.responses
        ]

        profile_row = await self._ensure_profile_row(user_id, None)
        preferences = self._parse_preferences(profile_row.get("preferences"))
        preferences["onboarding"] = {
            "responses": responses_payload,
            "completedAt": completed_at_utc.isoformat(),
        }

        onboarding_payload = {
            "user_id": user_id,
            "responses": responses_payload,
            "completed_at": completed_at_utc.isoformat(),
        }

        try:
            await self._client.insert("onboarding_responses", onboarding_payload)
        except httpx.HTTPError as exc:
            logger.error(
                "Failed to persist onboarding responses",
                user_id=user_id,
                error=str(exc),
            )

        await self._client.update(
            "profiles",
            {
                "onboarding_completed": True,
                "updated_at": datetime.now(UTC).isoformat(),
                "preferences": preferences,
            },
            filters={"id": f"eq.{user_id}"},
        )
        auth_user = await self._fetch_auth_user(user_id)
        return await self._build_user_profile(auth_user)

    async def schedule_account_deletion(self, user_id: str) -> AccountDeletionStatus:
        now = datetime.now(UTC)
        scheduled_for = now + timedelta(days=30)
        active_request = await self._get_active_deletion_request(user_id)
        if active_request:
            await self._client.update(
                "account_deletion_requests",
                {"scheduled_for": scheduled_for.isoformat()},
                filters={
                    "user_id": f"eq.{user_id}",
                    "cancelled_at": "is.null",
                    "completed_at": "is.null",
                },
            )
        else:
            await self._client.insert(
                "account_deletion_requests",
                {
                    "user_id": user_id,
                    "requested_at": now.isoformat(),
                    "scheduled_for": scheduled_for.isoformat(),
                },
            )

        return await self._get_active_deletion_request(user_id) or AccountDeletionStatus(
            scheduled_for=scheduled_for,
            requested_at=now,
        )

    async def cancel_pending_deletion(self, user_id: str) -> Optional[AccountDeletionStatus]:
        active_request = await self._get_active_deletion_request(user_id)
        if not active_request or not active_request.is_active:
            return active_request

        await self._client.update(
            "account_deletion_requests",
            {"cancelled_at": datetime.now(UTC).isoformat()},
            filters={
                "user_id": f"eq.{user_id}",
                "cancelled_at": "is.null",
                "completed_at": "is.null",
            },
        )
        return await self._get_active_deletion_request(user_id)

    async def sign_out(self, access_token: str) -> None:
        response = await self._client.auth.post(
            "/logout",
            headers={
                "Authorization": f"Bearer {access_token}",
                "apikey": self._settings.supabase_anon_key,
            },
        )
        if response.status_code not in (status.HTTP_200_OK, status.HTTP_204_NO_CONTENT):
            response.raise_for_status()

    async def _build_auth_response(self, data: Dict[str, Any]) -> AuthResponse:
        user_data = data.get("user", data)
        session = data.get("session", data)
        user = await self._build_user_profile(user_data)
        tokens = SessionTokens(
            access_token=session["access_token"],
            refresh_token=session.get("refresh_token"),
            expires_in=session.get("expires_in"),
        )
        return AuthResponse(user=user, session=tokens)

    async def _build_user_profile(self, data: Dict[str, Any]) -> UserProfile:
        auth_user = self._parse_auth_user(data)
        profile_row = await self._ensure_profile_row(auth_user["id"], auth_user.get("full_name"))
        deletion_status = await self._get_active_deletion_request(auth_user["id"])
        preferences = profile_row.get("preferences")

        return UserProfile(
            id=auth_user["id"],
            email=auth_user["email"],
            full_name=profile_row.get("full_name") or auth_user.get("full_name"),
            created_at=self._parse_datetime(auth_user.get("created_at")),
            last_sign_in_at=self._parse_datetime(auth_user.get("last_sign_in_at")),
            avatar_url=profile_row.get("avatar_url"),
            bio=profile_row.get("bio"),
            preferences=preferences if isinstance(preferences, dict) else None,
            onboarding_completed=bool(profile_row.get("onboarding_completed")),
            pending_account_deletion=deletion_status,
        )

    async def _merge_onboarding_preferences(
        self, user_id: str, onboarding_preferences: Dict[str, Any]
    ) -> Dict[str, Any]:
        profile_row = await self._ensure_profile_row(user_id, None)
        existing_preferences = profile_row.get("preferences") if profile_row else {}
        if not isinstance(existing_preferences, dict):
            existing_preferences = {}
        merged_preferences = dict(existing_preferences)
        merged_preferences["onboarding"] = onboarding_preferences
        return merged_preferences

    async def _ensure_profile_row(self, user_id: str, full_name: Optional[str]) -> Dict[str, Any]:
        existing = await self._fetch_profile_row(user_id)
        if existing:
            return existing

        payload: Dict[str, Any] = {
            "id": user_id,
            "created_at": datetime.now(UTC).isoformat(),
            "updated_at": datetime.now(UTC).isoformat(),
            "onboarding_completed": False,
        }
        if full_name:
            payload["full_name"] = full_name
        rows = await self._client.insert("profiles", payload)
        return rows[0] if rows else payload

    async def _fetch_profile_row(self, user_id: str) -> Optional[Dict[str, Any]]:
        rows = await self._client.select("profiles", filters={"id": f"eq.{user_id}"})
        return rows[0] if rows else None

    async def _get_active_deletion_request(self, user_id: str) -> Optional[AccountDeletionStatus]:
        rows = await self._client.select(
            "account_deletion_requests",
            filters={
                "user_id": f"eq.{user_id}",
                "cancelled_at": "is.null",
                "completed_at": "is.null",
            },
            order="scheduled_for.asc",
            limit=1,
        )
        if not rows:
            return None

        row = rows[0]
        status = AccountDeletionStatus(
            scheduled_for=self._parse_datetime(row.get("scheduled_for")),
            requested_at=self._parse_datetime(row.get("requested_at")),
            cancelled_at=self._parse_datetime(row.get("cancelled_at")),
            completed_at=self._parse_datetime(row.get("completed_at")),
        )
        return status

    async def _fetch_auth_user(self, user_id: str) -> Dict[str, Any]:
        response = await self._client.rest.get(
            "/auth.users",
            params={"id": f"eq.{user_id}"},
        )
        response.raise_for_status()
        payload = response.json()
        if not payload:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        return payload[0]

    @staticmethod
    def _parse_auth_user(data: Dict[str, Any]) -> Dict[str, Any]:
        user_metadata: Dict[str, Any] = data.get("user_metadata") or {}
        return {
            "id": data["id"],
            "email": data["email"],
            "full_name": user_metadata.get("full_name") or user_metadata.get("fullName"),
            "created_at": data.get("created_at"),
            "last_sign_in_at": data.get("last_sign_in_at"),
        }

    @staticmethod
    def _parse_datetime(value: Optional[str]) -> Optional[datetime]:
        if not value:
            return None
        return datetime.fromisoformat(value.replace("Z", "+00:00"))

    @staticmethod
    def _parse_preferences(value: Any) -> Dict[str, Any]:
        if isinstance(value, dict):
            return dict(value)
        if isinstance(value, str) and value:
            try:
                return json.loads(value)
            except json.JSONDecodeError:
                logger.warning("Failed to decode profile preferences JSON", raw=value)
        return {}
