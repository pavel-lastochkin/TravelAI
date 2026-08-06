# Travel AI Backend

FastAPI service that owns AI prompts, provider keys, and model routing.

The iOS app should call this API instead of Gemini directly.

## Local setup

Requires Python 3.11+ (Docker uses 3.12). Avoid the system Python shipped with Xcode if it is 3.9.

```bash
cd backend
python3.12 -m venv .venv   # or python3.11
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Put your Gemini API key in `.env`:

```bash
GEMINI_API_KEY=your_key_here
```

Run:

```bash
uvicorn app.main:app --reload --port 8000
```

Open docs:

- http://127.0.0.1:8000/health
- http://127.0.0.1:8000/docs

## API

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/health` | Deploy / monitoring check |
| POST | `/v1/places/analyze` | Photo → place recognition |
| POST | `/v1/places/details` | History + visit info |
| POST | `/v1/places/nearby` | Nearby suggestions |

### Analyze example

```bash
curl -X POST http://127.0.0.1:8000/v1/places/analyze \
  -F "image=@photo.jpg" \
  -F "language=Russian" \
  -F "latitude=25.1972" \
  -F "longitude=55.2744" \
  -F "location_source=photoMetadata"
```

## Working with Cursor + Xcode

This backend lives in the same git repo as the iOS app:

```text
Travel AI/
├── Travel AI/           # SwiftUI app (Xcode)
├── Travel AI.xcodeproj
├── docs/
└── backend/             # FastAPI (Cursor / terminal)
```

Recommended workflow:

1. Keep Xcode open for the iOS app.
2. In Cursor, open this same `Travel AI` folder.
3. Edit backend files under `backend/`.
4. Run the API locally with uvicorn.
5. Later point the iOS client to `http://127.0.0.1:8000` (simulator) or your Railway URL (device / TestFlight).

Do not put secrets in git. Use `.env` locally and Railway Variables in production.

## Railway deploy (for physical iPhone)

Backend must be on GitHub first (`backend/` folder committed and pushed).

1. Open [railway.com](https://railway.com) → **New Project** → **Deploy from GitHub repo**.
2. Choose `TravelAI`.
3. Open the created service → **Settings**:
   - **Root Directory** = `backend`
   - **Region** = **EU West (Amsterdam)** if available
   - Builder should pick up `Dockerfile`
4. **Variables** → add:
   - `GEMINI_API_KEY` = your key
   - `GEMINI_MODEL` = `gemini-2.5-flash`
   - `APP_ENV` = `production`
   - `MAX_IMAGE_BYTES` = `10485760`
   - `REQUEST_TIMEOUT_SECONDS` = `45`
5. **Settings → Networking** → **Generate Domain**.
6. Disable **Serverless / App Sleeping** so the first photo request is not cold.
7. Wait for deploy success, then open:
   - `https://YOUR_DOMAIN/health`
   - `https://YOUR_DOMAIN/docs`
8. Put the same HTTPS URL into local `Secrets.xcconfig`:

```text
BACKEND_BASE_URL = https://YOUR_DOMAIN
```

9. In Xcode: Clean Build Folder, then run on the physical iPhone.

Healthcheck path for Railway: `/health`
