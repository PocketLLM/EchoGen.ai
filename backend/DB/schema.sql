-- Enable useful extensions
create extension if not exists "pgcrypto";
create extension if not exists "uuid-ossp";

-- Helper trigger for automatic updated_at timestamps
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$ language plpgsql;

-- profiles table
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  bio text,
  preferences jsonb not null default '{}'::jsonb,
  onboarding_completed boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

drop trigger if exists set_updated_at_profiles on public.profiles;
create trigger set_updated_at_profiles
before update on public.profiles
for each row execute procedure public.set_updated_at();

-- account deletion requests (soft delete window)
create table if not exists public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  requested_at timestamptz not null default timezone('utc', now()),
  scheduled_for timestamptz not null,
  cancelled_at timestamptz,
  completed_at timestamptz
);
create index if not exists account_deletion_requests_user_id_idx on public.account_deletion_requests(user_id);
create index if not exists account_deletion_requests_scheduled_idx on public.account_deletion_requests(scheduled_for);

-- onboarding questionnaire responses
create table if not exists public.onboarding_responses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  responses jsonb not null,
  completed_at timestamptz not null,
  created_at timestamptz not null default timezone('utc', now())
);
create index if not exists onboarding_responses_user_id_idx on public.onboarding_responses(user_id);

-- user sessions
create table if not exists public.user_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  device jsonb,
  ip_address inet,
  created_at timestamptz not null default timezone('utc', now())
);
create index if not exists user_sessions_user_id_idx on public.user_sessions(user_id);

-- api keys
create table if not exists public.user_api_keys (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null,
  key_alias text,
  encrypted_key text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);
create index if not exists user_api_keys_user_id_idx on public.user_api_keys(user_id);
create index if not exists user_api_keys_provider_idx on public.user_api_keys(provider);

drop trigger if exists set_updated_at_user_api_keys on public.user_api_keys;
create trigger set_updated_at_user_api_keys
before update on public.user_api_keys
for each row execute procedure public.set_updated_at();

-- scraped content
create table if not exists public.scraped_content (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  url text not null,
  title text not null,
  markdown text not null,
  provider text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);
create index if not exists scraped_content_user_id_idx on public.scraped_content(user_id);
create index if not exists scraped_content_url_idx on public.scraped_content(url);

drop trigger if exists set_updated_at_scraped_content on public.scraped_content;
create trigger set_updated_at_scraped_content
before update on public.scraped_content
for each row execute procedure public.set_updated_at();

-- podcast scripts
create table if not exists public.podcast_scripts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source_content_id uuid references public.scraped_content(id) on delete set null,
  prompt text not null,
  model text not null,
  language text not null default 'en',
  segments jsonb not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);
create index if not exists podcast_scripts_user_id_idx on public.podcast_scripts(user_id);
create index if not exists podcast_scripts_source_idx on public.podcast_scripts(source_content_id);

drop trigger if exists set_updated_at_podcast_scripts on public.podcast_scripts;
create trigger set_updated_at_podcast_scripts
before update on public.podcast_scripts
for each row execute procedure public.set_updated_at();

-- generated podcasts
create table if not exists public.generated_podcasts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  script_id uuid not null references public.podcast_scripts(id) on delete cascade,
  audio_path text not null,
  cover_art_path text,
  duration_seconds integer,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);
create index if not exists generated_podcasts_user_id_idx on public.generated_podcasts(user_id);
create index if not exists generated_podcasts_script_id_idx on public.generated_podcasts(script_id);

drop trigger if exists set_updated_at_generated_podcasts on public.generated_podcasts;
create trigger set_updated_at_generated_podcasts
before update on public.generated_podcasts
for each row execute procedure public.set_updated_at();

-- processing jobs
create table if not exists public.processing_jobs (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  job_type text not null,
  status text not null default 'queued',
  payload jsonb not null default '{}'::jsonb,
  result jsonb,
  error text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  started_at timestamptz,
  finished_at timestamptz
);
create index if not exists processing_jobs_user_id_idx on public.processing_jobs(user_id);
create index if not exists processing_jobs_status_idx on public.processing_jobs(status);

drop trigger if exists set_updated_at_processing_jobs on public.processing_jobs;
create trigger set_updated_at_processing_jobs
before update on public.processing_jobs
for each row execute procedure public.set_updated_at();

-- usage events
create table if not exists public.usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb,
  cost_usd numeric(10,4),
  created_at timestamptz not null default timezone('utc', now())
);
create index if not exists usage_events_user_id_idx on public.usage_events(user_id);
create index if not exists usage_events_provider_idx on public.usage_events(provider);

-- Example RLS policy (apply variations per table)
-- alter table public.scraped_content enable row level security;
-- create policy "Individuals manage their content" on public.scraped_content
-- using (auth.uid() = user_id) with check (auth.uid() = user_id);
