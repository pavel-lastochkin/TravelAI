from __future__ import annotations

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "Travel AI Backend"
    app_env: str = "development"
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.5-flash"
    max_image_bytes: int = 10 * 1024 * 1024
    request_timeout_seconds: float = 45.0
    prompt_version_analyze: str = "analyze-v1"
    prompt_version_details: str = "details-v1"
    prompt_version_nearby: str = "nearby-v1"


@lru_cache
def get_settings() -> Settings:
    return Settings()
