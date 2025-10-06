# EchoGen.ai Task Tracker

A living checklist of the major efforts still in flight. Check off items as they ship and feel free to add sub-tasks per sprint.

## ✅ Legend
- [ ] Not started
- [~] In progress
- [x] Completed

## 🗂 Backend Migration
- [ ] Persist scraped URLs, scripts, and podcast metadata to Supabase instead of `SharedPreferences`.
- [ ] Proxy AI model catalog queries and script generation through FastAPI endpoints rather than direct client calls.
- [ ] Move Firecrawl and Hyperbrowser scraping into backend jobs with API key management server-side.
- [ ] Orchestrate TTS rendering via backend workers to centralize ElevenLabs/Gemini/OpenAI usage.
- [ ] Store provider API keys securely through backend secrets instead of local storage.

## 📱 Client Enhancements
- [ ] Replace local key validation screens with backend-driven status checks.
- [ ] Add deep links that open sponsor/support URLs directly in the system browser across all platforms.
- [ ] Expand accessibility tooling with transcript export, captions, and audio leveling controls.
- [ ] Introduce collaboration mode for shared script editing and review.

## 🚀 Delivery & Ops
- [ ] Harden CI to run `flutter test`, static analysis, and backend `pytest` on every pull request.
- [ ] Add release notes automation and changelog generation to GitHub Actions.
- [ ] Instrument analytics/telemetry (privacy-safe) to understand feature usage and drop-off points.

## 🎨 Landing Experience
- [~] Refresh marketing site sections to highlight new mobile workflow (copy draft in `LANDING_PAGE_PLAN.md`).
- [ ] Add interactive demo or embedded video walkthrough to the landing page.
