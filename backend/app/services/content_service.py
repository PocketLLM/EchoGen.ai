"""Content ingestion services."""
from __future__ import annotations

from typing import List

from fastapi import HTTPException, status

from ..core.database import SupabaseAsyncClient
from ..schemas.content import ScrapedContentCreate, ScrapedContentList, ScrapedContentResponse

SCRAPED_CONTENT_TABLE = "scraped_content"


class ContentService:
    def __init__(self, client: SupabaseAsyncClient) -> None:
        self._client = client

    async def create_scraped_content(self, user_id: str, payload: ScrapedContentCreate) -> ScrapedContentResponse:
        record = {
            "user_id": user_id,
            "url": str(payload.url),
            "title": payload.title,
            "markdown": payload.markdown,
            "provider": payload.provider,
            "metadata": payload.metadata,
        }
        response = await self._client.insert(SCRAPED_CONTENT_TABLE, record)
        return ScrapedContentResponse(**response[0])

    async def list_scraped_content(self, user_id: str, limit: int = 20, offset: int = 0) -> ScrapedContentList:
        response = await self._client.select(
            SCRAPED_CONTENT_TABLE,
            filters={"user_id": f"eq.{user_id}"},
            order="created_at.desc",
            limit=limit,
            offset=offset,
        )
        items = [ScrapedContentResponse(**item) for item in response]
        return ScrapedContentList(items=items, total=len(items))

    async def get_scraped_content(self, user_id: str, content_id: str) -> ScrapedContentResponse:
        response = await self._client.select(
            SCRAPED_CONTENT_TABLE,
            filters={"id": f"eq.{content_id}", "user_id": f"eq.{user_id}"},
            limit=1,
        )
        if not response:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
        return ScrapedContentResponse(**response[0])

    async def delete_scraped_content(self, user_id: str, content_id: str) -> None:
        await self._client.delete(
            SCRAPED_CONTENT_TABLE,
            filters={"id": f"eq.{content_id}", "user_id": f"eq.{user_id}"},
        )
