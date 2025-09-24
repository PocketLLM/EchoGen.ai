"""Job orchestration endpoints."""
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status

from ....schemas.auth import UserProfile
from ....schemas.jobs import JobCreate, JobStatus
from ...deps import get_current_user
from ....services.jobs import JobManager

router = APIRouter(prefix="/jobs", tags=["jobs"])


def get_job_manager(request: Request) -> JobManager:
    job_manager = getattr(request.app.state, "job_manager", None)
    if job_manager is None:
        raise RuntimeError("Job manager not configured")
    return job_manager


@router.post("", response_model=JobStatus, status_code=status.HTTP_202_ACCEPTED)
async def enqueue_job(
    payload: JobCreate,
    current_user: UserProfile = Depends(get_current_user),
    manager: JobManager = Depends(get_job_manager),
) -> JobStatus:
    try:
        return await manager.enqueue_job(current_user.id, payload)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc


@router.get("", response_model=List[JobStatus])
async def list_jobs(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: UserProfile = Depends(get_current_user),
    manager: JobManager = Depends(get_job_manager),
) -> List[JobStatus]:
    return await manager.list_jobs(current_user.id, limit=limit, offset=offset)


@router.get("/{job_id}", response_model=JobStatus)
async def get_job(
    job_id: str,
    current_user: UserProfile = Depends(get_current_user),
    manager: JobManager = Depends(get_job_manager),
) -> JobStatus:
    try:
        return await manager.get_job(current_user.id, job_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc
