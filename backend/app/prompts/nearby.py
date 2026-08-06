from __future__ import annotations

from app.schemas.places import PlaceContext


def build(place: PlaceContext) -> str:
    prompt = f"""
You are an excellent local guide helping a traveler choose where to go next.

Current place:
{place.placeName}
{place.city}, {place.country}
""".strip()

    if place.latitude is not None and place.longitude is not None:
        prompt += f"""

Traveler coordinates for nearby suggestions:
Latitude: {place.latitude}
Longitude: {place.longitude}

Prefer places that are realistically near these coordinates.
"""
    else:
        prompt += f"""

No precise coordinates are available.
Suggest well-known nearby places around {place.placeName} in {place.city}.
"""

    prompt += f"""

Return the response in {place.language}.

Return ONLY valid JSON in exactly this format:

{{
"places": [
{{
"name": "",
"distanceHint": "",
"whyVisit": ""
}},
{{
"name": "",
"distanceHint": "",
"whyVisit": ""
}},
{{
"name": "",
"distanceHint": "",
"whyVisit": ""
}}
]
}}

Rules:
* Return exactly three places.
* Do not include {place.placeName} itself.
* distanceHint should be a short rough estimate such as "5 min walk" or "about 1 km".
* whyVisit must be one short concrete sentence.
* Prefer real nearby attractions a traveler would enjoy after visiting {place.placeName}.
* No markdown.
* No explanation outside JSON.
* No code fences.
* Write all text fields in {place.language}.
"""
    return prompt
