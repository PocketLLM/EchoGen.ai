"""Schemas for managing provider API keys."""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class APIKeyCreate(BaseModel):
    provider: str = Field(..., description="Identifier for the AI provider (openai, gemini, etc.)")
    key_alias: Optional[str] = Field(None, description="Friendly display name")
    encrypted_key: str = Field(..., description="Encrypted API key payload")
    metadata: Optional[dict] = Field(default_factory=dict)


class APIKeyUpdate(BaseModel):
    key_alias: Optional[str] = None
    encrypted_key: Optional[str] = None
    metadata: Optional[dict] = None


class APIKeyResponse(BaseModel):
    id: str
    provider: str
    key_alias: Optional[str]
    metadata: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime
