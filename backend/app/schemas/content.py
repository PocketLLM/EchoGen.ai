"""Schemas for scraped content and user submissions."""
from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field, HttpUrl


class ScrapeSource(BaseModel):
    provider: str = Field(..., description="Provider responsible for scraping")
    url: HttpUrl
    title: Optional[str] = None
    thumbnail_url: Optional[HttpUrl] = None


class ScrapedContentCreate(BaseModel):
    url: HttpUrl
    title: str
    markdown: str = Field(..., description="Normalized article body")
    provider: str
    metadata: dict = Field(default_factory=dict)


class ScrapedContentResponse(BaseModel):
    id: str
    user_id: str
    url: HttpUrl
    title: str
    markdown: str
    provider: str
    metadata: dict
    created_at: datetime
    updated_at: datetime


class ScrapedContentList(BaseModel):
    items: List[ScrapedContentResponse]
    total: int
