"""Manage generated podcasts and associated media."""
from __future__ import annotations

from typing import List

from fastapi import HTTPException, status

from ..core.config import Settings
from ..core.database import SupabaseAsyncClient
from ..schemas.podcasts import PodcastCreate, PodcastDetailResponse, PodcastResponse
from ..schemas.scripts import ScriptResponse
from .storage_service import StorageService

PODCASTS_TABLE = "generated_podcasts"


class PodcastService:
    def __init__(self, client: SupabaseAsyncClient, storage: StorageService, settings: Settings) -> None:
        self._client = client
        self._storage = storage
        self._settings = settings

    async def create_podcast(self, user_id: str, payload: PodcastCreate) -> PodcastResponse:
        record = {
            "user_id": user_id,
            "script_id": payload.script_id,
            "audio_path": payload.audio_storage_path,
            "cover_art_path": payload.cover_art_storage_path,
            "duration_seconds": payload.duration_seconds,
            "metadata": payload.metadata,
        }
        response = await self._client.insert(PODCASTS_TABLE, record)
        return self._to_response(response[0])

    async def list_podcasts(self, user_id: str, limit: int = 20, offset: int = 0) -> List[PodcastResponse]:
        response = await self._client.select(
            PODCASTS_TABLE,
            filters={"user_id": f"eq.{user_id}"},
            order="created_at.desc",
            limit=limit,
            offset=offset,
        )
        return [self._to_response(item) for item in response]

    async def get_podcast(self, user_id: str, podcast_id: str) -> PodcastResponse:
        response = await self._client.select(
            PODCASTS_TABLE,
            filters={"id": f"eq.{podcast_id}", "user_id": f"eq.{user_id}"},
            limit=1,
        )
        if not response:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Podcast not found")
        return self._to_response(response[0])

    async def get_podcast_with_script(self, user_id: str, podcast_id: str) -> PodcastDetailResponse:
        response = await self._client.select(
            PODCASTS_TABLE,
            columns="*,script:podcast_scripts(*)",
            filters={"id": f"eq.{podcast_id}", "user_id": f"eq.{user_id}"},
            limit=1,
        )
        if not response:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Podcast not found")
        item = response[0]
        podcast = self._to_response(item)
        script_data = item.get("script")
        if not script_data:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Script not found for podcast")
        return PodcastDetailResponse(**podcast.model_dump(), script=ScriptResponse(**script_data))

    async def delete_podcast(self, user_id: str, podcast_id: str) -> None:
        await self._client.delete(PODCASTS_TABLE, filters={"id": f"eq.{podcast_id}", "user_id": f"eq.{user_id}"})

    def _to_response(self, data) -> PodcastResponse:
        audio_url = self._storage.build_public_url(self._settings.supabase_storage_bucket_audio, data["audio_path"])
        cover_path = data.get("cover_art_path")
        cover_url = (
            self._storage.build_public_url(self._settings.supabase_storage_bucket_art, cover_path)
            if cover_path
            else None
        )
        return PodcastResponse(
            id=data["id"],
            user_id=data["user_id"],
            script_id=data["script_id"],
            audio_url=audio_url,
            cover_art_url=cover_url,
            duration_seconds=data.get("duration_seconds"),
            metadata=data.get("metadata", {}),
            created_at=data["created_at"],
            updated_at=data["updated_at"],
        )
