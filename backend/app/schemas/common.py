"""Common Pydantic models shared across endpoints."""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class MessageResponse(BaseModel):
    message: str = Field(..., description="Human readable response message")


class Pagination(BaseModel):
    limit: int = Field(20, ge=1, le=100)
    offset: int = Field(0, ge=0)


class JobMetadata(BaseModel):
    job_id: str = Field(..., description="Server generated job identifier")
    status: str = Field(..., description="Current job status")
    submitted_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None
