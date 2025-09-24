# EchoGen.ai Agent Guide

## Repository Overview
- **Flutter client app** in `lib/` drives the EchoGen.ai podcast creation experience. `lib/main.dart` wires up global error handling, provider bootstrapping, audio session/service initialization, and launches the widget tree with theming managed by `ThemeProvider`. The UI is organized into feature-first screens in `lib/screens/`, shared widgets in `lib/widgets/`, business logic providers in `lib/providers/`, and reusable domain/services helpers in `lib/services/` and `lib/utils/`.
- **FastAPI backend** lives in `backend/` and exposes REST APIs for auth, content ingestion, script/podcast persistence, and background job management. `backend/main.py` composes routers from `backend/app/api/v1/endpoints/` and configures Supabase integrations, structured logging, and job handlers.
- **Documentation and assets** reside in `docs/`, `README.md`, and `lib/assets/`. Review `docs/imagerouter.md` and `LANDING_PAGE_PLAN.md` for product context, and keep screenshots/assets under version control when UI changes.

## Frontend Architecture
- `lib/providers/` contains `AuthProvider` for Supabase-auth flows (token bootstrap, onboarding, profile updates) and `ThemeProvider` for theme persistence.
- `lib/services/` encapsulates side-effectful operations:
  - `ai_service.dart` fetches model catalogs and drives script generation across Gemini, Groq, OpenAI, and OpenRouter using API keys stored in `SharedPreferences` (`api_key_<provider>`).
  - `web_scraping_service.dart` integrates with Firecrawl and Hyperbrowser APIs for URL scraping/batching, also using stored API keys (e.g., `api_key_firecrawl`).
  - `tts_service.dart`, `audio_handler.dart`, `global_audio_manager.dart`, and `background_audio_service.dart` power podcast rendering/playback via `just_audio`/`audio_service`.
  - `storage_service.dart` persists scraped URLs, scripts, and generated podcasts locally via `SharedPreferences` with capped history sizes.
  - `auth_api_service.dart` wraps backend endpoints; `token_storage.dart` keeps session tokens in `flutter_secure_storage`.
- Screen groups:
  - Auth/onboarding (`lib/screens/auth/`, `user_onboarding_screen.dart`).
  - Creation pipeline (scraping, script generation/preview, cover art, podcast generation/player) under `lib/screens/`.
  - Settings (`api_keys_screen.dart`, `profile_screen.dart`, `about_screen.dart`) and home tabs orchestrated by `home_screen.dart` with `MiniPlayerWidget` overlays.
- Common UI primitives live in `lib/widgets/` (app bar, bottom nav, mini player). `lib/constants/app_theme.dart` centralizes theme tokens.
- Keep styles aligned with `AppTheme` and prefer providers/services over duplicating network/storage code.

## Backend Architecture
- Settings & infrastructure:
  - `backend/app/core/config.py` loads environment via `pydantic-settings`; ensure Supabase keys and JWT secret are present before running the API.
  - `backend/app/core/database.py` exposes a lightweight async Supabase client cached via `get_supabase_client()`.
  - `backend/app/core/logging.py` configures `structlog`; `backend/app/core/middleware.py` registers common middlewares.
- API surface (`backend/app/api/v1/endpoints/`): modules for `auth`, `api_keys`, `content`, `scripts`, `podcasts`, and `jobs` that depend on services and auth dependencies in `backend/app/api/deps.py`.
- Services encapsulate persistence/business logic:
  - `auth_service.py` mirrors Supabase Auth REST endpoints, handles onboarding, account deletion lifecycle, and token verification.
  - `script_service.py`, `podcast_service.py`, `content_service.py`, and `storage_service.py` wrap Supabase table/storage interactions.
  - `services/jobs/job_manager.py` offers an in-process async job queue keyed by `JOBS_TABLE` and is registered at startup.
- Schemas under `backend/app/schemas/` define Pydantic models shared across endpoints.
- Backend tests live in `backend/tests/`; fixtures in `conftest.py` seed environment variables for isolated runs.

## Environment Setup & Tooling
### Flutter client
1. Install Flutter SDK ≥3.24 and Dart ≥3.5.
2. Run `flutter pub get` to install dependencies.
3. Execute `flutter analyze` and `flutter test` before committing changes.
4. Launch with `flutter run` or build artifacts via `flutter build <target>`.

### Backend API
1. Create a Python 3.12+ virtualenv and install deps: `pip install -r backend/requirements.txt` (includes `email-validator` required by Pydantic models).
2. Provide Supabase/JWT secrets via `backend/.env` (see `backend/app/core/config.py` for required variables).
3. Run the server with `uvicorn backend.main:app --reload`.
4. Execute unit tests using `pytest` from the `backend/` directory. Tests rely on `pytest-asyncio` markers—add the plugin if it is missing in your environment.

### Shared tooling
- Run `python -m compileall backend` to sanity-check backend syntax when FastAPI is unavailable.
- Lint/format Flutter code per `analysis_options.yaml` and avoid suppressing lints project-wide unless necessary.

## API Keys & Local Persistence
- Frontend expects users to enter provider credentials under Settings → API Keys, stored using `SharedPreferences` keys such as `api_key_gemini`, `api_key_firecrawl`, etc.
- Secure auth tokens use `TokenStorage` backed by `flutter_secure_storage`—access tokens are required for `AuthProvider.bootstrap()` to restore sessions.
- Generated assets (scripts/podcasts) are cached locally through `StorageService` with FIFO retention policies (50 scripts/URLs, 30 podcasts).

## Contribution Guidelines
- Respect existing provider/service abstractions; new integrations should extend the relevant service or add a new one rather than embedding network calls in widgets.
- Prefer dependency injection-friendly patterns (constructors accepting optional service instances) to ease testing (see `AuthProvider`).
- Document new endpoints in `docs/` and update README badges/feature lists if functionality changes materially.
- Keep the `AGENTS.md` file current when architectural decisions or workflow commands change.
