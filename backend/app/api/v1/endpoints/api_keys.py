"""API key management endpoints."""
from typing import List

from fastapi import APIRouter, Depends, status

from ....schemas.apikey import APIKeyCreate, APIKeyResponse, APIKeyUpdate
from ....schemas.auth import UserProfile
from ...deps import get_current_user, get_supabase_client_dep
from ....services.api_key_service import APIKeyService

router = APIRouter(prefix="/api-keys", tags=["api-keys"])


def get_api_key_service(client=Depends(get_supabase_client_dep)) -> APIKeyService:
    return APIKeyService(client)


@router.post("", response_model=APIKeyResponse, status_code=status.HTTP_201_CREATED)
async def create_api_key(
    payload: APIKeyCreate,
    current_user: UserProfile = Depends(get_current_user),
    service: APIKeyService = Depends(get_api_key_service),
) -> APIKeyResponse:
    return await service.create_api_key(current_user.id, payload)


@router.get("", response_model=List[APIKeyResponse])
async def list_api_keys(
    current_user: UserProfile = Depends(get_current_user),
    service: APIKeyService = Depends(get_api_key_service),
) -> List[APIKeyResponse]:
    return await service.list_api_keys(current_user.id)


@router.patch("/{key_id}", response_model=APIKeyResponse)
async def update_api_key(
    key_id: str,
    payload: APIKeyUpdate,
    current_user: UserProfile = Depends(get_current_user),
    service: APIKeyService = Depends(get_api_key_service),
) -> APIKeyResponse:
    return await service.update_api_key(current_user.id, key_id, payload)


@router.delete("/{key_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_api_key(
    key_id: str,
    current_user: UserProfile = Depends(get_current_user),
    service: APIKeyService = Depends(get_api_key_service),
) -> None:
    await service.delete_api_key(current_user.id, key_id)
