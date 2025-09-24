"""Schemas for generated podcast assets."""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field, HttpUrl

from .scripts import ScriptResponse


class PodcastCreate(BaseModel):
    script_id: str
    audio_storage_path: str = Field(..., description="Supabase Storage path to the audio file")
    cover_art_storage_path: Optional[str] = Field(None, description="Storage path for cover art")
    duration_seconds: Optional[int] = None
    metadata: dict = Field(default_factory=dict)


class PodcastResponse(BaseModel):
    id: str
    user_id: str
    script_id: str
    audio_url: HttpUrl
    cover_art_url: Optional[HttpUrl]
    duration_seconds: Optional[int]
    metadata: dict
    created_at: datetime
    updated_at: datetime


class PodcastDetailResponse(PodcastResponse):
    script: ScriptResponse
