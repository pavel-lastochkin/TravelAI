from __future__ import annotations

from app.schemas.places import PlaceContext


def build(place: PlaceContext) -> str:
    facts = "\n".join(f"- {fact}" for fact in place.quickFacts) or "- none"
    return f"""
You are an excellent local guide.

The traveler already received this first look at the place:

Place: {place.placeName}
City: {place.city}
Country: {place.country}
Quick facts:
{facts}
Opening story:
{place.story}

Now provide deeper content for two fixed app actions.
Return the response in {place.language}.

Return ONLY valid JSON in exactly this format:

{{
"history": "",
"visitInfo": ""
}}

Rules for history:
* 100-150 words.
* Tell one concrete memorable story about this place.
* Do NOT repeat the quick facts or opening story.
* Do NOT write a timeline or history lesson.
* Keep the tone warm and neutral, never brochure-like.

Rules for visitInfo:
* Explain what a traveler can visit or experience here.
* Cover main areas, viewpoints, or experiences when relevant.
* Mention when it is usually better to visit in general terms.
* Say if booking is typically useful.
* Do NOT invent exact current ticket prices or opening hours.
* If unsure about practical details, say so briefly and stay useful.
* Keep it concise: about 80-120 words.

Style rules:
* No markdown.
* No explanation outside JSON.
* No code fences.
* Never start with: "Wow!", "What a view!", "Can you believe...", "When I look at...", "I always think...", "You're looking at..."
* Write history and visitInfo in {place.language}.
""".strip()
