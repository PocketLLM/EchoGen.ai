"""Podcast script persistence."""
from __future__ import annotations

from typing import List

from fastapi import HTTPException, status

from ..core.database import SupabaseAsyncClient
from ..schemas.scripts import ScriptCreate, ScriptResponse

SCRIPTS_TABLE = "podcast_scripts"


class ScriptService:
    def __init__(self, client: SupabaseAsyncClient) -> None:
        self._client = client

    async def create_script(self, user_id: str, payload: ScriptCreate) -> ScriptResponse:
        record = {
            "user_id": user_id,
            "source_content_id": payload.source_content_id,
            "prompt": payload.prompt,
            "model": payload.model,
            "language": payload.language,
            "segments": [segment.model_dump() for segment in payload.segments],
            "metadata": payload.metadata,
        }
        response = await self._client.insert(SCRIPTS_TABLE, record)
        return ScriptResponse(**response[0])

    async def list_scripts(self, user_id: str, limit: int = 20, offset: int = 0) -> List[ScriptResponse]:
        response = await self._client.select(
            SCRIPTS_TABLE,
            filters={"user_id": f"eq.{user_id}"},
            order="created_at.desc",
            limit=limit,
            offset=offset,
        )
        return [ScriptResponse(**item) for item in response]

    async def get_script(self, user_id: str, script_id: str) -> ScriptResponse:
        response = await self._client.select(
            SCRIPTS_TABLE,
            filters={"id": f"eq.{script_id}", "user_id": f"eq.{user_id}"},
            limit=1,
        )
        if not response:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Script not found")
        return ScriptResponse(**response[0])

    async def delete_script(self, user_id: str, script_id: str) -> None:
        await self._client.delete(
            SCRIPTS_TABLE,
            filters={"id": f"eq.{script_id}", "user_id": f"eq.{user_id}"},
        )
