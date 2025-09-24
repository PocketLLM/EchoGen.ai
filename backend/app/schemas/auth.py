"""Authentication schemas mapping Supabase Auth payloads."""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class SignUpRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6)
    full_name: Optional[str] = Field(None, alias="fullName")


class SignInRequest(BaseModel):
    email: EmailStr
    password: str


class SessionTokens(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    expires_in: Optional[int] = None


class UserProfile(BaseModel):
    id: str
    email: EmailStr
    full_name: Optional[str] = Field(None, alias="fullName")
    created_at: datetime
    last_sign_in_at: Optional[datetime] = None


class AuthResponse(BaseModel):
    user: UserProfile
    session: SessionTokens


class VerifyTokenResponse(BaseModel):
    user: UserProfile
