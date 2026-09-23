create extension if not exists pgcrypto;

create table if not exists public.anamnesis (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  client_name text not null,
  birth_date date,
  phone text not null,
  email text,
  allergies text,
  eye_sensitivity text,
  contact_lenses text,
  recent_eye_issue text,
  medications text,
  previous_extensions text,
  previous_reaction text,
  lash_habits text,
  brow_procedures text,
  recent_skin_procedure text,
  skin_sensitivity text,
  desired_result text,
  procedure text,
  observations text,
  consent boolean not null default false,
  privacy boolean not null default false
);

create table if not exists public.admin_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  created_at timestamptz not null default now()
);

alter table public.anamnesis enable row level security;
-- Migration safety if the first version was already created with birth_date as text.
alter table public.anamnesis alter column birth_date type date using case when birth_date is null or birth_date = '' then null else birth_date::date end;
alter table public.admin_profiles enable row level security;

drop policy if exists "admin can read own profile" on public.admin_profiles;
create policy "admin can read own profile" on public.admin_profiles for select to authenticated using (id = auth.uid());

drop policy if exists "public can insert anamnesis" on public.anamnesis;
create policy "public can insert anamnesis" on public.anamnesis
  for insert to anon, authenticated
  with check (consent = true and privacy = true);

drop policy if exists "admin can read anamnesis" on public.anamnesis;
create policy "admin can read anamnesis" on public.anamnesis
  for select to authenticated
  using (exists (select 1 from public.admin_profiles p where p.id = auth.uid()));

drop policy if exists "admin can update anamnesis" on public.anamnesis;
create policy "admin can update anamnesis" on public.anamnesis
  for update to authenticated
  using (exists (select 1 from public.admin_profiles p where p.id = auth.uid()))
  with check (exists (select 1 from public.admin_profiles p where p.id = auth.uid()));

drop policy if exists "admin can delete anamnesis" on public.anamnesis;
create policy "admin can delete anamnesis" on public.anamnesis
  for delete to authenticated
  using (exists (select 1 from public.admin_profiles p where p.id = auth.uid()));

-- Username -> email lookup used by the login screen.
-- It returns the Auth email only for an exact username match.
create or replace function public.get_admin_email(p_username text)
returns text
language sql
security definer
set search_path = public
as $$
  select u.email
  from auth.users u
  join public.admin_profiles p on p.id = u.id
  where p.username = p_username
  limit 1;
$$;

revoke all on function public.get_admin_email(text) from public;
grant execute on function public.get_admin_email(text) to anon, authenticated;
