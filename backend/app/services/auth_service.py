"""Service for interacting with Supabase Auth."""
from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, Optional

from fastapi import HTTPException, status

from ..core.config import Settings
from ..core.database import SupabaseAsyncClient
from ..schemas.auth import AuthResponse, SessionTokens, SignInRequest, SignUpRequest, UserProfile, VerifyTokenResponse


class AuthService:
    """Wrapper around Supabase Auth REST endpoints."""

    def __init__(self, client: SupabaseAsyncClient, settings: Settings) -> None:
        self._client = client
        self._settings = settings

    async def sign_up(self, payload: SignUpRequest) -> AuthResponse:
        metadata: Dict[str, Any] = {}
        if payload.full_name:
            metadata["full_name"] = payload.full_name

        request_body: Dict[str, Any] = {"email": payload.email, "password": payload.password}
        if metadata:
            request_body["data"] = metadata

        response = await self._client.auth.post(
            "/signup",
            json=request_body,
        )
        response.raise_for_status()
        data = response.json()
        return self._parse_auth_response(data)

    async def sign_in(self, payload: SignInRequest) -> AuthResponse:
        response = await self._client.auth.post(
            "/token?grant_type=password",
            json={"email": payload.email, "password": payload.password},
        )
        if response.status_code == status.HTTP_400_BAD_REQUEST:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        response.raise_for_status()
        data = response.json()
        return self._parse_auth_response(data)

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
        user = self._parse_user(data.get("user", data))
        return VerifyTokenResponse(user=user)

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

    def _parse_auth_response(self, data: Dict[str, Any]) -> AuthResponse:
        user = self._parse_user(data.get("user", data))
        session = data.get("session", data)
        tokens = SessionTokens(
            access_token=session["access_token"],
            refresh_token=session.get("refresh_token"),
            expires_in=session.get("expires_in"),
        )
        return AuthResponse(user=user, session=tokens)

    def _parse_user(self, data: Dict[str, Any]) -> UserProfile:
        user_metadata: Dict[str, Any] = data.get("user_metadata") or {}
        full_name: Optional[str] = user_metadata.get("full_name") or user_metadata.get("fullName")
        created_at = self._parse_datetime(data.get("created_at"))
        last_sign_in_at = self._parse_datetime(data.get("last_sign_in_at"))
        return UserProfile(
            id=data["id"],
            email=data["email"],
            full_name=full_name,
            created_at=created_at,
            last_sign_in_at=last_sign_in_at,
        )

    @staticmethod
    def _parse_datetime(value: Optional[str]) -> Optional[datetime]:
        if not value:
            return None
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
