"""Authentication endpoints backed by Supabase Auth."""
from typing import Optional

from fastapi import APIRouter, Depends, Header, HTTPException, status

from ....schemas.auth import (
    AccountDeletionStatus,
    AuthResponse,
    OnboardingSubmission,
    ProfileUpdateRequest,
    SignInRequest,
    SignUpRequest,
    UserProfile,
)
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


@router.get("/users/{user_id}", response_model=UserProfile)
async def get_user_by_id(
    user_id: str,
    current_user: UserProfile = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service),
) -> UserProfile:
    if current_user.id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only access your own profile")
    return await auth_service.get_user_by_id(user_id)


@router.patch("/profile", response_model=UserProfile)
async def update_profile(
    payload: ProfileUpdateRequest,
    current_user: UserProfile = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service),
) -> UserProfile:
    return await auth_service.update_profile(current_user.id, payload)


@router.post("/onboarding", response_model=UserProfile)
async def submit_onboarding(
    payload: OnboardingSubmission,
    current_user: UserProfile = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service),
) -> UserProfile:
    return await auth_service.submit_onboarding(current_user.id, payload)


@router.delete("/account", response_model=AccountDeletionStatus)
async def schedule_account_deletion(
    current_user: UserProfile = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service),
) -> AccountDeletionStatus:
    return await auth_service.schedule_account_deletion(current_user.id)


@router.post("/account/cancel", response_model=Optional[AccountDeletionStatus])
async def cancel_account_deletion(
    current_user: UserProfile = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service),
) -> Optional[AccountDeletionStatus]:
    return await auth_service.cancel_pending_deletion(current_user.id)


@router.post("/signout", status_code=status.HTTP_204_NO_CONTENT)
async def sign_out(
    authorization: str = Header(..., alias="Authorization"),
    auth_service: AuthService = Depends(get_auth_service),
) -> None:
    token = authorization.split(" ", 1)[1]
    await auth_service.sign_out(token)
