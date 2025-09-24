"""Endpoints for generated podcasts."""
from typing import List

from fastapi import APIRouter, Depends, Query, status

from ....schemas.auth import UserProfile
from ....schemas.podcasts import PodcastCreate, PodcastDetailResponse, PodcastResponse
from ...deps import get_current_user, get_settings_dep, get_supabase_client_dep
from ....services.podcast_service import PodcastService
from ....services.storage_service import StorageService

router = APIRouter(prefix="/podcasts", tags=["podcasts"])


def get_podcast_service(
    client=Depends(get_supabase_client_dep),
    settings=Depends(get_settings_dep),
) -> PodcastService:
    storage = StorageService(client, settings)
    return PodcastService(client, storage, settings)


@router.post("", response_model=PodcastResponse, status_code=status.HTTP_201_CREATED)
async def create_podcast(
    payload: PodcastCreate,
    current_user: UserProfile = Depends(get_current_user),
    service: PodcastService = Depends(get_podcast_service),
) -> PodcastResponse:
    return await service.create_podcast(current_user.id, payload)


@router.get("", response_model=List[PodcastResponse])
async def list_podcasts(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: UserProfile = Depends(get_current_user),
    service: PodcastService = Depends(get_podcast_service),
) -> List[PodcastResponse]:
    return await service.list_podcasts(current_user.id, limit=limit, offset=offset)


@router.get("/{podcast_id}", response_model=PodcastResponse)
async def get_podcast(
    podcast_id: str,
    current_user: UserProfile = Depends(get_current_user),
    service: PodcastService = Depends(get_podcast_service),
) -> PodcastResponse:
    return await service.get_podcast(current_user.id, podcast_id)


@router.get("/{podcast_id}/with-script", response_model=PodcastDetailResponse)
async def get_podcast_with_script(
    podcast_id: str,
    current_user: UserProfile = Depends(get_current_user),
    service: PodcastService = Depends(get_podcast_service),
) -> PodcastDetailResponse:
    return await service.get_podcast_with_script(current_user.id, podcast_id)


@router.delete("/{podcast_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_podcast(
    podcast_id: str,
    current_user: UserProfile = Depends(get_current_user),
    service: PodcastService = Depends(get_podcast_service),
) -> None:
    await service.delete_podcast(current_user.id, podcast_id)
