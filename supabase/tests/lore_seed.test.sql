-- Test for supabase/seeds/lore_entries.sql. Run from the repository root (the
-- \i paths are relative), after stub_supabase.sql and schema.sql, on a fresh
-- database, with `psql -v ON_ERROR_STOP=1`.
--
-- The seed file runs unmodified: this test creates the account whose email is
-- the seed's placeholder. The "no matching account" error path is checked by a
-- separate step in .github/workflows/schema.yml, because a failing \i cannot be
-- caught from inside a psql script.

\set ON_ERROR_STOP on
\set QUIET on

-- Earlier tests may have left rows for other users; remember how many, so the
-- test can show that the seed does not touch them.
create temp table seed_baseline as select count(*)::int as n from public.lore_entries;

insert into auth.users (id, email)
values ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'REPLACE_WITH_YOUR_LOGIN_EMAIL');

\i supabase/seeds/lore_entries.sql
-- second run must not create duplicates
\i supabase/seeds/lore_entries.sql

do $$
declare
  owner_id constant uuid := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
  n int;
  r record;
begin
  select count(*) into n from public.lore_entries where user_id = owner_id;
  if n <> 2 then raise exception 'FAIL: expected 2 seeded entries for the owner, found %', n; end if;
  select count(*) into n from public.lore_entries where user_id <> owner_id;
  if n <> (select b.n from seed_baseline b) then
    raise exception 'FAIL: rows of other users changed from % to %', (select b.n from seed_baseline b), n;
  end if;
  raise notice 'PASS: seed is idempotent (2 entries after 2 runs) and leaves other users rows alone';

  select * into r from public.lore_entries
  where user_id = owner_id and title = 'Boundary Failure: Vessel [16] emptied';
  if r.id is null
     or r.iteration_code <> '2394829084924924924G'
     or r.planet_id is not null
     or r.source <> 'Boundary Failure terminal'
     or array_length(string_to_array(r.original_text, E'\n'), 1) <> 5
     or array_length(string_to_array(r.translation_vi, E'\n'), 1) <> 5 then
    raise exception 'FAIL: Boundary Failure entry is wrong: %', r;
  end if;
  raise notice 'PASS: Boundary Failure entry (5 original + 5 translated lines)';

  select * into r from public.lore_entries
  where user_id = owner_id and title = 'Starship Autodiagnostics (opening)';
  if r.id is null
     or r.iteration_code <> '2394829084924924924G'
     or r.planet_id is not null
     or r.source <> 'Starship Autodiagnostics'
     or array_length(string_to_array(r.original_text, E'\n'), 1) <> 6
     or array_length(string_to_array(r.translation_vi, E'\n'), 1) <> 6 then
    raise exception 'FAIL: Starship Autodiagnostics entry is wrong: %', r;
  end if;
  raise notice 'PASS: Starship Autodiagnostics entry (6 original + 6 translated lines)';
end $$;
