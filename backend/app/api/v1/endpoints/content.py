"""Content ingestion endpoints."""
from fastapi import APIRouter, Depends, Query, status

from ....schemas.auth import UserProfile
from ....schemas.content import ScrapedContentCreate, ScrapedContentList, ScrapedContentResponse
from ...deps import get_current_user, get_supabase_client_dep
from ....services.content_service import ContentService

router = APIRouter(prefix="/content", tags=["content"])


def get_content_service(client=Depends(get_supabase_client_dep)) -> ContentService:
    return ContentService(client)


@router.post("", response_model=ScrapedContentResponse, status_code=status.HTTP_201_CREATED)
async def create_content(
    payload: ScrapedContentCreate,
    current_user: UserProfile = Depends(get_current_user),
    service: ContentService = Depends(get_content_service),
) -> ScrapedContentResponse:
    return await service.create_scraped_content(current_user.id, payload)


@router.get("", response_model=ScrapedContentList)
async def list_content(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: UserProfile = Depends(get_current_user),
    service: ContentService = Depends(get_content_service),
) -> ScrapedContentList:
    return await service.list_scraped_content(current_user.id, limit=limit, offset=offset)


@router.get("/{content_id}", response_model=ScrapedContentResponse)
async def get_content(
    content_id: str,
    current_user: UserProfile = Depends(get_current_user),
    service: ContentService = Depends(get_content_service),
) -> ScrapedContentResponse:
    return await service.get_scraped_content(current_user.id, content_id)


@router.delete("/{content_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_content(
    content_id: str,
    current_user: UserProfile = Depends(get_current_user),
    service: ContentService = Depends(get_content_service),
) -> None:
    await service.delete_scraped_content(current_user.id, content_id)
