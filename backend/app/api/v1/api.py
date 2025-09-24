"""Version 1 API router."""
from fastapi import APIRouter

from .endpoints import api_keys, auth, content, jobs, podcasts, scripts

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(api_keys.router)
api_router.include_router(content.router)
api_router.include_router(scripts.router)
api_router.include_router(podcasts.router)
api_router.include_router(jobs.router)
