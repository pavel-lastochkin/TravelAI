from __future__ import annotations

import json
import re
from typing import Optional, TypeVar

import httpx
from pydantic import BaseModel, ValidationError

from app.config import Settings
from app.prompts import analyze as analyze_prompts
from app.prompts import details as details_prompts
from app.prompts import nearby as nearby_prompts
from app.providers.base import AIProvider
from app.schemas.places import NearbyPlacesResult, PlaceContext, PlaceDetailContent, PlaceRecognitionResult

T = TypeVar("T", bound=BaseModel)


class GeminiProviderError(RuntimeError):
    pass


class GeminiProvider(AIProvider):
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._endpoint = (
            f"https://generativelanguage.googleapis.com/v1/models/"
            f"{settings.gemini_model}:generateContent"
        )

    async def analyze_place(
        self,
        *,
        image_bytes: bytes,
        mime_type: str,
        language: str,
        latitude: Optional[float],
        longitude: Optional[float],
        location_source: Optional[str],
    ) -> PlaceRecognitionResult:
        prompt = analyze_prompts.build(
            language=language,
            latitude=latitude,
            longitude=longitude,
            location_source=location_source,
        )
        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": prompt},
                        {
                            "inline_data": {
                                "mime_type": mime_type,
                                "data": _encode_image(image_bytes),
                            }
                        },
                    ]
                }
            ]
        }
        return await self._generate_json(payload, PlaceRecognitionResult)

    async def fetch_place_details(self, place: PlaceContext) -> PlaceDetailContent:
        prompt = details_prompts.build(place)
        payload = {"contents": [{"parts": [{"text": prompt}]}]}
        return await self._generate_json(payload, PlaceDetailContent)

    async def fetch_nearby_places(self, place: PlaceContext) -> NearbyPlacesResult:
        prompt = nearby_prompts.build(place)
        payload = {"contents": [{"parts": [{"text": prompt}]}]}
        return await self._generate_json(payload, NearbyPlacesResult)

    async def _generate_json(self, payload: dict, model_type: type[T]) -> T:
        if not self._settings.gemini_api_key:
            raise GeminiProviderError(
                "GEMINI_API_KEY is missing. Add it to backend/.env or Railway Variables."
            )

        async with httpx.AsyncClient(timeout=self._settings.request_timeout_seconds) as client:
            response = await client.post(
                self._endpoint,
                headers={
                    "Content-Type": "application/json",
                    "x-goog-api-key": self._settings.gemini_api_key,
                },
                json=payload,
            )

        if response.status_code != 200:
            raise GeminiProviderError(
                f"Gemini API error (HTTP {response.status_code}): {response.text[:500]}"
            )

        body = response.json()
        try:
            text = body["candidates"][0]["content"]["parts"][0]["text"]
        except (KeyError, IndexError, TypeError) as exc:
            raise GeminiProviderError("Gemini returned an empty or unexpected response.") from exc

        cleaned = _sanitize_json_response(text)
        try:
            return model_type.model_validate_json(cleaned)
        except ValidationError as exc:
            raise GeminiProviderError(
                f"Could not parse Gemini JSON into {model_type.__name__}: {exc}"
            ) from exc


def _encode_image(image_bytes: bytes) -> str:
    import base64

    return base64.b64encode(image_bytes).decode("ascii")


def _sanitize_json_response(text: str) -> str:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
        cleaned = re.sub(r"\s*```$", "", cleaned)
        cleaned = cleaned.strip()

    start = cleaned.find("{")
    end = cleaned.rfind("}")
    if start != -1 and end != -1 and end > start:
        cleaned = cleaned[start : end + 1]

    # Validate it is JSON before returning.
    json.loads(cleaned)
    return cleaned
