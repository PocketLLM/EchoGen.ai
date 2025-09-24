# EchoGen.ai Backend

The backend service provides a secure, modular API for the EchoGen.ai application. It exposes
FastAPI endpoints for authentication, content ingestion, AI processing jobs, and media delivery
while delegating persistence and authentication to Supabase.

## 🧱 Architecture Overview

```
backend/
├── app
│   ├── api
│   │   └── v1
│   │       ├── endpoints/        # FastAPI route handlers grouped by domain
│   │       └── api.py            # Combined API router
│   ├── core/                     # Application configuration, logging, middleware
│   ├── schemas/                  # Pydantic models used by the API
│   ├── services/                 # Supabase integration and domain logic
│   └── utils/                    # Shared helpers (IDs, timestamps, etc.)
├── DB/
│   ├── schema.md                 # Human readable data model documentation
│   └── schema.sql                # Supabase (PostgreSQL) schema definition
├── API_DOCUMENTATION.md          # Endpoint reference and usage flows
├── requirements.txt              # Python dependencies
└── main.py                       # FastAPI application factory
```

Key design principles:

- **Supabase First** – Authentication, row level security, storage, and job/event persistence
  are delegated to Supabase using RESTful APIs.
- **Async Everywhere** – The backend uses asynchronous HTTP clients and background tasks to
  keep the API responsive while AI workloads run in the background.
- **Modular Services** – Each feature (auth, content, podcasts, jobs, storage) has a dedicated
  service class with a thin API layer and rich domain schemas.
- **Documented & Testable** – The repository includes schema diagrams, request/response
  contracts, and a skeleton `pytest` suite for rapid iteration.

## 🚀 Getting Started

1. **Install dependencies**

   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r backend/requirements.txt
   ```

2. **Copy the example environment**

   ```bash
   cp backend/.env.example backend/.env
   ```

   Fill the file with your Supabase project credentials (see [Configuration](#configuration)).

3. **Run database migrations**

   Execute the SQL in `backend/DB/schema.sql` via the Supabase SQL editor. The accompanying
   `schema.md` explains the relationships and recommended storage buckets.

4. **Start the API server**

   ```bash
   uvicorn backend.main:app --reload
   ```

   Visit `http://localhost:8000/docs` for the automatically generated Swagger UI.

## ⚙️ Configuration

The backend relies on the following environment variables (see `backend/.env.example`):

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL (https://your-project.supabase.co) |
| `SUPABASE_ANON_KEY` | Public anon key used for client-side auth flows |
| `SUPABASE_SERVICE_ROLE_KEY` | Service key with elevated privileges for the backend |
| `SUPABASE_STORAGE_BUCKET_AUDIO` | Bucket name for generated podcast audio |
| `SUPABASE_STORAGE_BUCKET_ART` | Bucket name for AI-generated cover art |
| `SUPABASE_STORAGE_BUCKET_TRANSCRIPTS` | Bucket for transcripts and scripts |
| `JWT_SECRET` | Secret used to sign internal service tokens |
| `JWT_ALGORITHM` | Algorithm (default `HS256`) |
| `API_RATE_LIMIT_PER_MINUTE` | Optional rate limit override for user sessions |

## 🧠 Feature Alignment with Flutter App

The backend data model mirrors the Flutter features:

- **User management** – Supabase Auth handles sign-up, email verification, password reset.
- **API key vault** – Authenticated users can store provider credentials (OpenAI, Gemini,
  ElevenLabs, ImageRouter, etc.) with optional encryption at rest.
- **Content ingestion** – Scraped URLs, manual text, and uploaded transcripts are persisted to
  support cross-device library syncing.
- **Podcast generation** – AI generation runs as asynchronous jobs tracked through Supabase's
  `jobs` table. Each job produces media assets stored in Supabase Storage buckets and metadata in
  the `podcasts` table.
- **Session history & analytics** – Sessions tie user actions, API usage, and credits together
  for billing and monitoring.

See `backend/API_DOCUMENTATION.md` for endpoint-level details and `backend/DB/schema.md` for table
relationships.

## 🧪 Testing

Run the starter test suite and lint checks before committing changes:

```bash
pytest backend/tests
python -m compileall backend
```

The provided tests focus on configuration wiring and service contracts. Extend them as you
implement domain logic.

## 📦 Deployment Notes

- The service is stateless; deploy behind a load balancer with HTTPS termination.
- Configure Supabase Row Level Security (RLS) policies as described in `backend/DB/schema.md` to
  protect user data.
- Use a background worker (Celery, RQ, or Supabase Edge Functions) for long-running AI tasks when
  scaling beyond the in-process background job manager provided in this skeleton.
- Enable observability by forwarding logs to your preferred platform (Datadog, Grafana, etc.).

## 📚 Additional Documentation

- [`backend/API_DOCUMENTATION.md`](API_DOCUMENTATION.md) – Request/response contracts and flow
  diagrams.
- [`backend/DB/schema.md`](DB/schema.md) – Supabase schema reference and bucket layout.
- [`LANDING_PAGE_PLAN.md`](../LANDING_PAGE_PLAN.md) – Product positioning inspiration from the
  front-end.

Happy building! 🎉
