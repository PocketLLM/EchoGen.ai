"""Endpoints for managing podcast scripts."""
from typing import List

from fastapi import APIRouter, Depends, Query, status

from ....schemas.auth import UserProfile
from ....schemas.scripts import ScriptCreate, ScriptResponse
from ...deps import get_current_user, get_supabase_client_dep
from ....services.script_service import ScriptService

router = APIRouter(prefix="/scripts", tags=["scripts"])


def get_script_service(client=Depends(get_supabase_client_dep)) -> ScriptService:
    return ScriptService(client)


@router.post("", response_model=ScriptResponse, status_code=status.HTTP_201_CREATED)
async def create_script(
    payload: ScriptCreate,
    current_user: UserProfile = Depends(get_current_user),
    service: ScriptService = Depends(get_script_service),
) -> ScriptResponse:
    return await service.create_script(current_user.id, payload)


@router.get("", response_model=List[ScriptResponse])
async def list_scripts(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: UserProfile = Depends(get_current_user),
    service: ScriptService = Depends(get_script_service),
) -> List[ScriptResponse]:
    return await service.list_scripts(current_user.id, limit=limit, offset=offset)


@router.get("/{script_id}", response_model=ScriptResponse)
async def get_script(
    script_id: str,
    current_user: UserProfile = Depends(get_current_user),
    service: ScriptService = Depends(get_script_service),
) -> ScriptResponse:
    return await service.get_script(current_user.id, script_id)


@router.delete("/{script_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_script(
    script_id: str,
    current_user: UserProfile = Depends(get_current_user),
    service: ScriptService = Depends(get_script_service),
) -> None:
    await service.delete_script(current_user.id, script_id)
