# EchoGen.ai Backend API (v1)

The backend exposes a modular FastAPI application organised under the `/api/v1` prefix.
All endpoints require HTTPS and JSON payloads. Authentication relies on Supabase Auth
JWTs obtained during sign-in.

## Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/auth/signup` | Create a Supabase user and return session tokens |
| `POST` | `/api/v1/auth/signin` | Authenticate a user via email/password |
| `GET`  | `/api/v1/auth/me` | Return the authenticated user's profile |
| `POST` | `/api/v1/auth/signout` | Invalidate the current Supabase session |

### Sign-up

```http
POST /api/v1/auth/signup
Content-Type: application/json

{
  "email": "creator@example.com",
  "password": "P@ssw0rd!",
  "fullName": "Podcast Creator"
}
```

Response includes the Supabase user and session tokens:

```json
{
  "user": {
    "id": "uuid",
    "email": "creator@example.com",
    "fullName": "Podcast Creator",
    "created_at": "2024-05-18T10:25:00+00:00"
  },
  "session": {
    "access_token": "<jwt>",
    "refresh_token": "<refresh>",
    "expires_in": 3600
  }
}
```

Use the access token for authorised requests:

```
Authorization: Bearer <access_token>
```

## API Key Vault

Authenticated users can securely store encrypted provider credentials (OpenAI, Gemini,
ElevenLabs, ImageRouter, etc.). Keys are encrypted client-side before being sent to the backend.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/api-keys` | Create a new provider credential |
| `GET`  | `/api/v1/api-keys` | List credentials for the current user |
| `PATCH` | `/api/v1/api-keys/{key_id}` | Update metadata or rotated key |
| `DELETE` | `/api/v1/api-keys/{key_id}` | Remove a credential |

## Content Ingestion

The Flutter app stores scraped URLs, manual transcripts, and metadata to enable syncing across devices.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/content` | Persist a scraped article or uploaded transcript |
| `GET`  | `/api/v1/content` | List recent content items |
| `GET`  | `/api/v1/content/{content_id}` | Retrieve a specific article |
| `DELETE` | `/api/v1/content/{content_id}` | Remove a content record |

Sample payload:

```json
{
  "url": "https://example.com/blog-post",
  "title": "Understanding AI Podcasts",
  "markdown": "# Heading\nLong-form content...",
  "provider": "firecrawl",
  "metadata": {
    "language": "en",
    "author": "AI Team"
  }
}
```

## Script Library

Podcast scripts are stored as structured segments. The app can render them locally or request
text-to-speech jobs.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/scripts` | Save a generated script |
| `GET`  | `/api/v1/scripts` | List scripts |
| `GET`  | `/api/v1/scripts/{script_id}` | Retrieve a script |
| `DELETE` | `/api/v1/scripts/{script_id}` | Delete a script |

Script payload example:

```json
{
  "source_content_id": "uuid",
  "prompt": "Create a friendly podcast explaining machine learning",
  "model": "gemini-1.5-pro",
  "language": "en",
  "segments": [
    {"speaker": "Alex", "content": "Welcome to EchoGen.ai!"},
    {"speaker": "Jordan", "content": "Today we explore ML basics."}
  ],
  "metadata": {"tone": "educational"}
}
```

## Podcast Generation & Storage

Each rendered podcast references the script that produced it and media stored in Supabase Storage.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/podcasts` | Register a generated podcast asset |
| `GET`  | `/api/v1/podcasts` | List podcasts |
| `GET`  | `/api/v1/podcasts/{podcast_id}` | Retrieve podcast metadata |
| `GET`  | `/api/v1/podcasts/{podcast_id}/with-script` | Retrieve podcast metadata with embedded script |
| `DELETE` | `/api/v1/podcasts/{podcast_id}` | Delete a podcast record |

The `audio_storage_path` and `cover_art_storage_path` fields should reference Supabase Storage
objects (e.g. `podcasts/user-uuid/audio/file.mp3`). Public URLs are derived on the fly.

## Asynchronous Job Processing

Long-running AI tasks execute asynchronously via the in-process job manager. Jobs are tracked in
the `processing_jobs` table and can be polled by the Flutter client.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/jobs` | Enqueue a job (returns 202 with job metadata) |
| `GET`  | `/api/v1/jobs` | List recent jobs |
| `GET`  | `/api/v1/jobs/{job_id}` | Inspect job status and results |

Example job request:

```json
{
  "job_type": "script_generation",
  "payload": {
    "content_id": "uuid",
    "model": "gemini-1.5-pro",
    "prompt": "Summarise the article into a 5-minute podcast"
  }
}
```

### Job Status Lifecycle

1. **queued** – Job record created.
2. **running** – Handler picked up the job.
3. **succeeded** – `result` contains handler output (e.g. script ID, audio path).
4. **failed** – `error` column includes the traceback snippet.

The default implementation registers mock handlers for `script_generation` and `audio_render`.
Replace `_mock_job_handler` in `backend/main.py` with real integrations (e.g., Celery tasks or
Supabase Edge Functions).

## Error Handling

Errors use standard HTTP status codes with structured payloads:

```json
{
  "detail": "Content not found"
}
```

Rate limiting, audit logging, and detailed error telemetry should be added via middleware when
deploying to production.
