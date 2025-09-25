"""FastAPI application entrypoint for EchoGen.ai backend."""
import asyncio
from typing import Dict

from fastapi import FastAPI

from app.api.v1.api import api_router
from app.core.config import get_settings
from app.core.database import get_supabase_client
from app.core.logging import configure_logging, get_logger
from app.core.middleware import register_middlewares
from app.schemas.jobs import JobCreate
from app.services.jobs import JobManager

settings = get_settings()
configure_logging()
logger = get_logger(__name__)

app = FastAPI(
    title=settings.project_name, 
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc"
)
register_middlewares(app, settings)


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring and load balancers."""
    return {
        "status": "healthy",
        "service": "EchoGen.ai API",
        "version": "0.1.0",
        "environment": settings.environment
    }


app.include_router(api_router, prefix=settings.api_v1_prefix)


async def _mock_job_handler(job: JobCreate) -> Dict[str, str]:
    """Placeholder job handler that simulates async processing."""

    await asyncio.sleep(0.1)
    return {"echo": job.payload}


@app.on_event("startup")
async def on_startup() -> None:
    logger.info("Starting EchoGen.ai backend")
    client = get_supabase_client(settings)
    job_manager = JobManager(client)
    job_manager.register_handler("script_generation", _mock_job_handler)
    job_manager.register_handler("audio_render", _mock_job_handler)
    app.state.job_manager = job_manager


@app.on_event("shutdown")
async def on_shutdown() -> None:
    logger.info("Shutting down EchoGen.ai backend")
    client = get_supabase_client(settings)
    await client.close()


__all__ = ["app"]
