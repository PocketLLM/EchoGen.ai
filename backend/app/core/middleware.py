"""Application middleware configuration."""
from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from .config import Settings


ALLOWED_ORIGINS = ["*"]


def register_middlewares(app: FastAPI, settings: Settings) -> None:
    """Register middleware used by the FastAPI application."""

    app.add_middleware(
        CORSMiddleware,
        allow_origins=ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
        expose_headers=["X-Request-ID", "X-Job-ID"],
    )

    # Additional middleware (metrics, rate limiting, request ID) can be registered here
