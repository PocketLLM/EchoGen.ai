# EchoGen.ai Backend API (v1)

hosted url= https://echo-gen-ai.vercel.app/
hosted health = https://echo-gen-ai.vercel.app/health
hosted docs=https://echo-gen-ai.vercel.app/docs

The backend exposes a modular FastAPI application organised under the `/api/v1` prefix.
All endpoints require HTTPS and JSON payloads. Authentication relies on Supabase Auth
JWTs obtained during sign-in.

## Authentication

The authentication API wraps Supabase Auth and augments it with profile management,
onboarding, and delayed account deletion logic.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/auth/signup` | Create a Supabase user (email or phone) and return session tokens |
| `POST` | `/api/v1/auth/signin` | Authenticate via email/phone + password and cancel pending deletions |
| `GET`  | `/api/v1/auth/me` | Decode the bearer token and return the cached profile |
| `GET`  | `/api/v1/auth/users/{id}` | Fetch the freshest profile data from Supabase |
| `PATCH` | `/api/v1/auth/profile` | Update profile fields (name, avatar, bio, preferences) |
| `POST` | `/api/v1/auth/onboarding` | Persist onboarding survey responses |
| `DELETE` | `/api/v1/auth/account` | Schedule account deletion in 30 days |
| `POST` | `/api/v1/auth/account/cancel` | Cancel a pending deletion request |
| `POST` | `/api/v1/auth/signout` | Invalidate the current Supabase session |

### Sign-up

```http
POST /api/v1/auth/signup
Content-Type: application/json

{
  "method": "email",
  "email": "creator@example.com",
  "password": "Sup3rSecure!",
  "fullName": "Podcast Creator"
}
```

To sign up with a phone number supply the SMS-ready number and password:

```http
POST /api/v1/auth/signup
Content-Type: application/json

{
  "method": "phone",
  "phoneNumber": "+13334445555",
  "password": "Sup3rSecure!"
}
```

> **Coming soon** – set `"method": "google" | "apple" | "github"` to receive a
> `501 Not Implemented` response for roadmap authentication options.

Response includes the Supabase user and session tokens:

```json
{
  "user": {
    "id": "uuid",
    "email": "creator@example.com",
    "fullName": "Podcast Creator",
    "created_at": "2024-05-18T10:25:00+00:00",
    "avatarUrl": null,
    "bio": null,
    "onboardingCompleted": false,
    "pendingAccountDeletion": null
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

### Sign-in

```http
POST /api/v1/auth/signin
Authorization: Bearer <none>
Content-Type: application/json

{
  "method": "email",
  "email": "creator@example.com",
  "password": "Sup3rSecure!"
}
```

When a user signs in successfully the backend automatically cancels any pending account
deletion requests created in the previous 30-day window.

Phone logins also accept a password and route through Supabase's password grant:

```http
POST /api/v1/auth/signin
Authorization: Bearer <none>
Content-Type: application/json

{
  "method": "phone",
  "phoneNumber": "+13334445555",
  "password": "Sup3rSecure!"
}
```

### Fetch profile & manage preferences

```http
GET /api/v1/auth/users/{user_id}
Authorization: Bearer <access_token>
```

```http
PATCH /api/v1/auth/profile
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "fullName": "Echo Creator",
  "avatarUrl": "https://cdn.example.com/profile/123.png",
  "bio": "Community host and AI storyteller",
  "preferences": {
    "primaryVoice": "serene",
    "preferredLength": "10_minute",
    "newsletterOptIn": true
  }
}
```

### Onboarding survey

Triggered after the first successful sign-in.

```http
POST /api/v1/auth/onboarding
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "responses": [
    {
      "questionId": "format",
      "question": "What format inspires you the most?",
      "answer": "Interview"
    },
    {
      "questionId": "cadence",
      "question": "How frequently do you plan to publish?",
      "answer": "Weekly"
    }
  ]
}
```

### Account deletion window

```http
DELETE /api/v1/auth/account
Authorization: Bearer <access_token>
```

Response:

```json
{
  "scheduled_for": "2024-06-18T10:25:00+00:00",
  "requested_at": "2024-05-19T10:25:00+00:00",
  "cancelled_at": null,
  "completed_at": null
}
```

Any subsequent sign-in before the `scheduled_for` timestamp will automatically cancel the
request. Users may also call `POST /api/v1/auth/account/cancel` directly.

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
