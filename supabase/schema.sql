-- NMS Planet Notebook initial schema
-- Run in Supabase SQL Editor for a NEW project.
-- All application tables are private to the authenticated owner.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.star_systems (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  name text not null,
  galaxy text,
  system_coordinates text,
  portal_glyphs text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.planets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  system_id uuid references public.star_systems(id) on delete set null,
  name text not null,
  planet_type text,
  weather text,
  sentinels text,
  flora text,
  fauna text,
  resources text,
  planet_coordinates text,
  discovery_status text not null default 'unknown'
    check (discovery_status in ('unknown', 'visited', 'discovered', 'uploaded')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.planet_images (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  planet_id uuid not null references public.planets(id) on delete cascade,
  storage_path text not null,
  caption text,
  created_at timestamptz not null default now(),
  unique (storage_path)
);

create table if not exists public.missions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  title text not null,
  status text not null default 'todo'
    check (status in ('todo', 'in_progress', 'completed', 'paused')),
  planet_id uuid references public.planets(id) on delete set null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists star_systems_user_id_idx on public.star_systems(user_id);
create index if not exists planets_user_id_idx on public.planets(user_id);
create index if not exists planets_system_id_idx on public.planets(system_id);
create index if not exists planet_images_planet_id_idx on public.planet_images(planet_id);
create index if not exists planet_images_user_id_idx on public.planet_images(user_id);
create index if not exists missions_user_id_idx on public.missions(user_id);

alter table public.star_systems enable row level security;
alter table public.planets enable row level security;
alter table public.planet_images enable row level security;
alter table public.missions enable row level security;

drop policy if exists "owner manages own star systems" on public.star_systems;
create policy "owner manages own star systems"
on public.star_systems for all to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

drop policy if exists "owner manages own planets" on public.planets;
create policy "owner manages own planets"
on public.planets for all to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and (
    system_id is null
    or exists (
      select 1 from public.star_systems s
      where s.id = system_id and s.user_id = (select auth.uid())
    )
  )
);

drop policy if exists "owner manages own planet images" on public.planet_images;
create policy "owner manages own planet images"
on public.planet_images for all to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.planets p
    where p.id = planet_id and p.user_id = (select auth.uid())
  )
);

drop policy if exists "owner manages own missions" on public.missions;
create policy "owner manages own missions"
on public.missions for all to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and (
    planet_id is null
    or exists (
      select 1 from public.planets p
      where p.id = planet_id and p.user_id = (select auth.uid())
    )
  )
);

drop trigger if exists star_systems_updated_at on public.star_systems;
create trigger star_systems_updated_at before update on public.star_systems
for each row execute function public.set_updated_at();

drop trigger if exists planets_updated_at on public.planets;
create trigger planets_updated_at before update on public.planets
for each row execute function public.set_updated_at();

drop trigger if exists missions_updated_at on public.missions;
create trigger missions_updated_at before update on public.missions
for each row execute function public.set_updated_at();

-- Storage:
-- Create a PRIVATE bucket named nms-planet-images in the Supabase Dashboard.
-- Storage policies are intentionally a separate step because they depend on the
-- chosen object path convention. Do not make the bucket public.
