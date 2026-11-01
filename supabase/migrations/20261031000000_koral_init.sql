-- Koral database: profiles, projects, generated results, daily AI usage.
-- Apply with `npx supabase db push`, or paste into the Supabase SQL editor.
-- Every table has row-level security on. The app only uses the anon key,
-- so these rules are what actually protect people's data.

-- Profiles ------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  role text not null default 'member' check (role in ('member', 'owner')),
  created_at timestamptz not null default now()
);

-- Create a profile automatically when someone signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'owner'
  );
$$;

-- Projects ------------------------------------------------------------------

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  kind text not null
    check (kind in ('social_post', 'document', 'slides', 'video_script')),
  language text not null default 'English'
    check (char_length(language) between 1 and 40),
  brief text not null default '' check (char_length(brief) <= 4000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index projects_owner_updated_idx
  on public.projects (owner_id, updated_at desc);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger projects_touch_updated_at
  before update on public.projects
  for each row execute function public.touch_updated_at();

-- Generated results (written only by the server) -----------------------------

create table public.generations (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  owner_id uuid not null references auth.users (id) on delete cascade,
  output text not null,
  model text,
  created_at timestamptz not null default now()
);

create index generations_project_created_idx
  on public.generations (project_id, created_at desc);

-- Daily AI usage (written only by the server) --------------------------------

create table public.ai_usage (
  user_id uuid not null references auth.users (id) on delete cascade,
  day date not null default ((now() at time zone 'utc')::date),
  requests integer not null default 0 check (requests >= 0),
  primary key (user_id, day)
);

-- Uses one request if the person is under today's limit. Atomic, so two taps
-- at once can't both slip past the limit. Returns false when the limit is hit.
create or replace function public.consume_ai_request(p_user uuid, p_limit integer)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count integer;
begin
  insert into public.ai_usage as u (user_id, day, requests)
  values (p_user, (now() at time zone 'utc')::date, 1)
  on conflict (user_id, day)
    do update set requests = u.requests + 1
    where u.requests < p_limit
  returning u.requests into v_count;
  return v_count is not null;
end;
$$;

-- Gives a request back when the AI provider fails, so people aren't charged
-- for errors that weren't theirs.
create or replace function public.refund_ai_request(p_user uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.ai_usage
  set requests = greatest(requests - 1, 0)
  where user_id = p_user
    and day = (now() at time zone 'utc')::date;
$$;

-- Owner totals. Counts only: the owner never reads other people's work.
create or replace function public.admin_stats()
returns json
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_owner() then
    raise exception 'Only the owner can see these numbers.'
      using errcode = '42501';
  end if;
  return json_build_object(
    'users', (select count(*) from public.profiles),
    'projects', (select count(*) from public.projects),
    'generations', (select count(*) from public.generations),
    'requests_today', (
      select coalesce(sum(requests), 0) from public.ai_usage
      where day = (now() at time zone 'utc')::date
    )
  );
end;
$$;

-- Who may call which function -----------------------------------------------

revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.consume_ai_request(uuid, integer) from public, anon, authenticated;
revoke execute on function public.refund_ai_request(uuid) from public, anon, authenticated;
grant execute on function public.consume_ai_request(uuid, integer) to service_role;
grant execute on function public.refund_ai_request(uuid) to service_role;

revoke execute on function public.admin_stats() from public, anon;
grant execute on function public.admin_stats() to authenticated;

-- Row-level security --------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.generations enable row level security;
alter table public.ai_usage enable row level security;

-- Read your own profile. There is no update policy, so nobody can make
-- themselves owner from the app. Set the owner in the SQL editor instead.
create policy "Read own profile" on public.profiles
  for select to authenticated
  using (id = (select auth.uid()));

create policy "Read own projects" on public.projects
  for select to authenticated
  using (owner_id = (select auth.uid()));

create policy "Create own projects" on public.projects
  for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "Update own projects" on public.projects
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "Delete own projects" on public.projects
  for delete to authenticated
  using (owner_id = (select auth.uid()));

-- Results and usage are readable by their owner and written only by the
-- generate function, so nobody can fake results or reset their own count.
create policy "Read own results" on public.generations
  for select to authenticated
  using (owner_id = (select auth.uid()));

create policy "Read own usage" on public.ai_usage
  for select to authenticated
  using (user_id = (select auth.uid()));
