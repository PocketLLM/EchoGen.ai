"""Authentication schemas mapping Supabase Auth payloads."""
from datetime import UTC, datetime
from enum import Enum
from typing import Any, Dict, List, Optional

from pydantic import (
    BaseModel,
    ConfigDict,
    EmailStr,
    Field,
    HttpUrl,
    field_validator,
    model_validator,
)


class AuthMethod(str, Enum):
    """Supported authentication mechanisms."""

    EMAIL = "email"
    PHONE = "phone"
    GOOGLE = "google"
    APPLE = "apple"
    GITHUB = "github"


class SignUpRequest(BaseModel):
    """Payload for creating a new user."""

    method: AuthMethod = Field(default=AuthMethod.EMAIL)
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(default=None, min_length=8)
    full_name: Optional[str] = Field(default=None, alias="fullName")
    phone_number: Optional[str] = Field(default=None, alias="phoneNumber")

    @model_validator(mode="after")
    def _ensure_identifiers(cls, values: "SignUpRequest") -> "SignUpRequest":
        if values.method == AuthMethod.EMAIL:
            if not values.email:
                raise ValueError("email is required when method=email")
            if not values.password:
                raise ValueError("password is required when method=email")
        if values.method == AuthMethod.PHONE:
            if not values.phone_number:
                raise ValueError("phoneNumber is required when method=phone")
            if not values.password:
                raise ValueError("password is required when method=phone")
        return values


class SignInRequest(BaseModel):
    """Payload for authenticating a user."""

    method: AuthMethod = Field(default=AuthMethod.EMAIL)
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = Field(default=None, alias="phoneNumber")
    password: Optional[str] = None
    otp: Optional[str] = Field(default=None, min_length=4, max_length=12)

    @model_validator(mode="after")
    def _ensure_credentials(cls, values: "SignInRequest") -> "SignInRequest":
        if values.method == AuthMethod.EMAIL:
            if not values.email or not values.password:
                raise ValueError("email and password are required when method=email")
        elif values.method == AuthMethod.PHONE:
            if not values.phone_number or not values.password:
                raise ValueError("phoneNumber and password are required when method=phone")
        return values


class SessionTokens(BaseModel):
    """JWT tokens returned by Supabase."""

    access_token: str
    refresh_token: Optional[str] = None
    expires_in: Optional[int] = None


class AccountDeletionStatus(BaseModel):
    """Represents the state of a delayed account deletion request."""

    scheduled_for: Optional[datetime] = None
    requested_at: Optional[datetime] = None
    cancelled_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None

    @property
    def is_active(self) -> bool:
        return bool(self.scheduled_for and not self.cancelled_at and not self.completed_at)


class UserProfile(BaseModel):
    """Extended profile returned to the client."""

    id: str
    email: EmailStr
    full_name: Optional[str] = Field(default=None, alias="fullName")
    created_at: datetime
    last_sign_in_at: Optional[datetime] = None
    avatar_url: Optional[HttpUrl | str] = Field(default=None, alias="avatarUrl")
    bio: Optional[str] = None
    preferences: Optional[Dict[str, Any]] = None
    onboarding_completed: bool = Field(default=False, alias="onboardingCompleted")
    pending_account_deletion: Optional[AccountDeletionStatus] = Field(
        default=None, alias="pendingAccountDeletion"
    )


class AuthResponse(BaseModel):
    """Response returned after successful authentication."""

    user: UserProfile
    session: SessionTokens


class VerifyTokenResponse(BaseModel):
    user: UserProfile


class ProfileUpdateRequest(BaseModel):
    """Partial update for the profile record."""

    full_name: Optional[str] = Field(default=None, alias="fullName")
    avatar_url: Optional[HttpUrl | str] = Field(default=None, alias="avatarUrl")
    bio: Optional[str] = None
    preferences: Optional[Dict[str, Any]] = None

    @field_validator("preferences")
    @classmethod
    def _ensure_preferences_serialisable(cls, value: Optional[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        if value is None:
            return value
        # Ensures nested values are JSON serialisable
        try:
            import json

            json.dumps(value)
        except TypeError as exc:  # pragma: no cover - defensive
            raise ValueError("preferences must be JSON serialisable") from exc
        return value


class OnboardingAnswer(BaseModel):
    """Represents a single onboarding question and answer."""

    model_config = ConfigDict(populate_by_name=True)

    question_id: str = Field(alias="questionId")
    question: str
    answer: Any


class OnboardingSubmission(BaseModel):
    """Onboarding payload collected after first sign in."""

    model_config = ConfigDict(populate_by_name=True)

    responses: List[OnboardingAnswer]
    completed_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
