-- Minimal stand-in for the Supabase pieces that supabase/schema.sql depends on,
-- so the schema can be applied to a plain PostgreSQL database (used by CI).
-- This is NOT real Supabase: it only provides auth.users, auth.uid() and the
-- authenticated/anon roles with the table grants Supabase gives them.
--
-- WARNING: only run this on a throwaway PostgreSQL database. Never run it in a
-- real Supabase project: it replaces auth.uid() and inserts fake auth.users rows.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
end
$$;

create schema if not exists auth;
create table if not exists auth.users (id uuid primary key);

-- Supabase reads the caller from the JWT claims; the tests set this setting.
create or replace function auth.uid() returns uuid
language sql stable
as $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;

grant usage on schema auth to authenticated, anon;
grant execute on function auth.uid() to authenticated, anon;
grant usage on schema public to authenticated, anon;

-- Supabase grants table privileges to both roles; RLS is what restricts rows.
alter default privileges in schema public grant all on tables to authenticated, anon;

insert into auth.users (id) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb')
on conflict (id) do nothing;
