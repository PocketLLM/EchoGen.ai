"""Application configuration using environment variables."""
from functools import lru_cache

from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Centralized application settings loaded from environment variables."""

    model_config = SettingsConfigDict(env_file=("backend/.env", ".env"), case_sensitive=False)

    project_name: str = "EchoGen.ai API"
    api_v1_prefix: str = "/api/v1"

    supabase_url: AnyHttpUrl
    supabase_anon_key: str
    supabase_service_role_key: str

    supabase_storage_bucket_audio: str = "podcast-audio"
    supabase_storage_bucket_art: str = "cover-art"
    supabase_storage_bucket_transcripts: str = "transcripts"

    jwt_secret: str
    jwt_algorithm: str = "HS256"
    api_rate_limit_per_minute: int = 120

    environment: str = "local"

    # AI Service Provider API Keys
    gemini_api_key: str = ""
    openai_api_key: str = ""
    groq_api_key: str = ""
    openrouter_api_key: str = ""

    # Web Scraping Service API Keys
    firecrawl_api_key: str = ""
    hyperbrowser_api_key: str = ""

    # Image Generation Service API Keys
    imagerouter_api_key: str = ""

    # Development Environment Configuration
    app_environment: str = "development"
    api_timeout_seconds: int = 30
    max_retries: int = 3
    debug_mode: bool = False

    @field_validator("supabase_anon_key", "supabase_service_role_key")
    @classmethod
    def _ensure_not_placeholder(cls, value: str) -> str:
        if not value or value.startswith("your-"):
            raise ValueError(
                "Supabase keys must be provided via environment variables. "
                "Update backend/.env before starting the server."
            )
        return value

    @property
    def supabase_rest_url(self) -> str:
        return f"{str(self.supabase_url).rstrip('/')}/rest/v1"

    @property
    def supabase_auth_url(self) -> str:
        return f"{str(self.supabase_url).rstrip('/')}/auth/v1"

    @property
    def supabase_storage_url(self) -> str:
        return f"{str(self.supabase_url).rstrip('/')}/storage/v1"


@lru_cache
def get_settings() -> Settings:
    """Return a cached Settings instance."""

    return Settings()  # type: ignore[arg-type]


settings = get_settings()
