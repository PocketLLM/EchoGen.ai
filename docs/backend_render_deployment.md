# EchoGen.ai Backend Deployment on Render

This guide walks through deploying the EchoGen.ai FastAPI backend to [Render](https://render.com) and exposing a production-ready URL that the Flutter client can consume.

## 1. Prerequisites

Before you start, make sure you have:

- A Render account with access to create Web Services.
- A GitHub (or GitLab/Bitbucket) repository containing this project with the `backend/` folder at the root of the repo.
- A Supabase project that already has the schema from [`backend/DB/schema.sql`](../backend/DB/schema.sql) applied and Row-Level Security policies configured per [`backend/DB/schema.md`](../backend/DB/schema.md).
- Production-ready values for all environment variables defined in [`backend/.env.example`](../backend/.env.example) (Supabase URL/keys, JWT secret, storage bucket names, etc.).
- Optional but recommended: a custom domain managed in Render for the API hostname you will share with the Flutter app.

## 2. Prepare the Repository

Render will build directly from your Git repository. Ensure the following before deploying:

1. Commit any pending backend changes and push to the branch you plan to deploy (e.g., `main`).
2. Confirm the backend works locally:
   ```bash
   pip install -r backend/requirements.txt
   uvicorn backend.main:app --reload
   ```
3. Visit `http://localhost:8000/docs` to confirm the API loads and responds to requests.
4. If you use Git submodules or private dependencies, configure Render with the necessary credentials (Deploy Settings → Advanced → *Add SSH Key*).

## 3. Create a Web Service on Render

1. In the Render dashboard, click **New → Web Service**.
2. Connect the Git repository that contains EchoGen.ai.
3. In the service configuration form, set:
   - **Name**: e.g., `echogen-backend`.
   - **Region**: choose the closest region to your users.
   - **Branch**: the branch to deploy (typically `main`).
   - **Runtime**: **Python 3**.
   - **Root Directory**: `backend` (this tells Render to build from the backend folder rather than the Flutter client).
   - **Build Command**: `pip install -r requirements.txt`.
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port ${PORT}`.
   - **Instance Type**: start with **Starter**; scale up if you need more CPU/RAM.

4. Click **Advanced → Environment** and add the variables from your production `.env` file. The table should include at minimum:

   | Key | Value |
   | --- | ----- |
   | `SUPABASE_URL` | `https://<your-project>.supabase.co` |
   | `SUPABASE_ANON_KEY` | Supabase anon key |
   | `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key |
   | `SUPABASE_STORAGE_BUCKET_AUDIO` | Storage bucket for generated audio |
   | `SUPABASE_STORAGE_BUCKET_ART` | Storage bucket for cover art |
   | `SUPABASE_STORAGE_BUCKET_TRANSCRIPTS` | Storage bucket for transcripts |
   | `JWT_SECRET` | Strong secret used for signing tokens |
   | `JWT_ALGORITHM` | Usually `HS256` |
   | `API_RATE_LIMIT_PER_MINUTE` | Optional override (defaults to `120`) |

   > **Tip:** Add any additional secrets you reference in custom services (e.g., third-party AI providers) so the backend can proxy requests if needed.

5. (Optional) Add a **Secret File** named `.env` with the same contents if you prefer environment files over individual variables.
6. Click **Create Web Service**. Render will install dependencies, boot the app, and perform a health check on the `/` endpoint.

## 4. Verify the Deployment

1. Once the service status is **Live**, Render will assign a URL like `https://echogen-backend.onrender.com`.
2. Visit `https://<your-service>.onrender.com/docs` to confirm the FastAPI Swagger UI loads.
3. Use the "Authorize" button in Swagger to test authenticated endpoints with a Supabase JWT.
4. If you plan to use a custom domain, add it under **Settings → Custom Domains** and follow Render's DNS instructions.

## 5. Configure the Flutter App

Update the Flutter client so it points to the deployed backend:

1. Locate the environment/configuration file where backend URLs are defined (for example, a constants file or `.env` in the Flutter app).
2. Replace the development URL (`http://localhost:8000`) with the Render URL (or your custom domain).
3. If the Flutter app supports multiple environments, add a production configuration pointing to the Render host.
4. Redeploy the Flutter app or publish an updated build with the new backend endpoint.

## 6. Continuous Deployment Tips

- Enable **Auto Deploy** on the Render service so pushes to the selected branch trigger a rebuild.
- Use Render's **Deploy Hooks** if you prefer to trigger deployments manually or from CI.
- Monitor logs under **Logs** in the Render dashboard or forward them to an external service (Datadog, Logtail, etc.).
- Configure **Health Checks** (Settings → Health Checks) to probe `/health` or another lightweight endpoint once you add one, ensuring the service is restarted if it becomes unresponsive.

## 7. Troubleshooting

| Symptom | Likely Cause | Fix |
| ------- | ------------ | --- |
| Deploy fails during build | Dependencies are missing or private | Confirm the `requirements.txt` installs without prompts locally; add private repo keys under **Advanced** settings. |
| Service boots but returns 500s | Missing environment variables or Supabase credentials | Double-check Render environment variables match your `.env` file. |
| Requests time out | Long-running AI jobs blocking FastAPI worker | Offload heavy work to background jobs or scale up the instance type. |
| Flutter app rejects TLS certificate | Custom domain misconfigured | Complete HTTPS setup in Render (auto-managed certificates) and ensure the Flutter app trusts the domain. |

Once deployed, the Render URL serves as the base API endpoint for the Flutter app and any external integrations.
