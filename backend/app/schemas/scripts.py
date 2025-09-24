"""Schemas for AI generated podcast scripts."""
from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class ScriptSegment(BaseModel):
    speaker: str
    content: str
    start_time: Optional[float] = Field(None, description="Start time in seconds")
    end_time: Optional[float] = Field(None, description="End time in seconds")


class ScriptCreate(BaseModel):
    source_content_id: Optional[str] = Field(None, description="FK to scraped content")
    prompt: str = Field(..., description="Prompt or notes used to drive the AI model")
    model: str = Field(..., description="AI model identifier")
    language: str = Field("en")
    segments: List[ScriptSegment]
    metadata: dict = Field(default_factory=dict)


class ScriptResponse(BaseModel):
    id: str
    user_id: str
    source_content_id: Optional[str]
    prompt: str
    model: str
    language: str
    segments: List[ScriptSegment]
    metadata: dict
    created_at: datetime
    updated_at: datetime
