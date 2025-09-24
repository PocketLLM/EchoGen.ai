"""Reusable FastAPI dependencies."""
from fastapi import Depends, Header, HTTPException, status

from ..core.config import Settings, get_settings
from ..core.database import SupabaseAsyncClient, get_supabase_client
from ..services.auth_service import AuthService


async def get_settings_dep() -> Settings:
    return get_settings()


def get_supabase_client_dep(settings: Settings = Depends(get_settings_dep)) -> SupabaseAsyncClient:
    return get_supabase_client(settings)


def get_auth_service(
    settings: Settings = Depends(get_settings_dep),
    client: SupabaseAsyncClient = Depends(get_supabase_client_dep),
) -> AuthService:
    return AuthService(client, settings)


async def get_current_user(
    authorization: str = Header(..., alias="Authorization"),
    auth_service: AuthService = Depends(get_auth_service),
):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing Bearer token")
    token = authorization.split(" ", 1)[1]
    result = await auth_service.verify_access_token(token)
    return result.user
