"""Schemas representing async job execution."""
from datetime import datetime
from typing import Any, Dict, Optional

from pydantic import BaseModel, Field


class JobCreate(BaseModel):
    job_type: str = Field(..., description="Identifier of the job (script_generation, tts, etc.)")
    payload: Dict[str, Any] = Field(default_factory=dict)


class JobStatus(BaseModel):
    id: str
    job_type: str
    status: str
    payload: Dict[str, Any]
    result: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    started_at: Optional[datetime] = None
    finished_at: Optional[datetime] = None
