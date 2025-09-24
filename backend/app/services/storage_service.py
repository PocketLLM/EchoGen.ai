"""Utility helpers for Supabase Storage buckets."""
from __future__ import annotations

from ..core.config import Settings
from ..core.database import SupabaseAsyncClient


class StorageService:
    def __init__(self, client: SupabaseAsyncClient, settings: Settings) -> None:
        self._client = client
        self._settings = settings

    def build_public_url(self, bucket: str, path: str) -> str:
        return f"{self._settings.supabase_storage_url}/object/public/{bucket}/{path}".replace("//object", "/object")

    async def create_signed_url(self, bucket: str, path: str, expires_in: int = 3600) -> str:
        response = await self._client.storage.post(
            f"/object/sign/{bucket}",
            json={"paths": [{"path": path, "expiresIn": expires_in}]},
        )
        response.raise_for_status()
        data = response.json()
        if not data:
            raise RuntimeError("Failed to create signed URL")
        signed_path = data[0]["signedURL"]
        return f"{self._settings.supabase_storage_url}{signed_path}"
