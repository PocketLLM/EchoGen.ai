"""Authentication endpoints backed by Supabase Auth."""
from fastapi import APIRouter, Depends, Header, status

from ....schemas.auth import AuthResponse, SignInRequest, SignUpRequest, UserProfile
from ...deps import get_auth_service, get_current_user
from ....services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def sign_up(payload: SignUpRequest, auth_service: AuthService = Depends(get_auth_service)) -> AuthResponse:
    return await auth_service.sign_up(payload)


@router.post("/signin", response_model=AuthResponse)
async def sign_in(payload: SignInRequest, auth_service: AuthService = Depends(get_auth_service)) -> AuthResponse:
    return await auth_service.sign_in(payload)


@router.get("/me", response_model=UserProfile)
async def get_profile(current_user: UserProfile = Depends(get_current_user)) -> UserProfile:
    return current_user


@router.post("/signout", status_code=status.HTTP_204_NO_CONTENT)
async def sign_out(
    authorization: str = Header(..., alias="Authorization"),
    auth_service: AuthService = Depends(get_auth_service),
) -> None:
    token = authorization.split(" ", 1)[1]
    await auth_service.sign_out(token)
