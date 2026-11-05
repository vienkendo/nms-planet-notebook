-- Smoke test for public.lore_entries (constraints, RLS, planet ownership,
-- updated_at trigger, ON DELETE SET NULL). Run after stub_supabase.sql and
-- schema.sql, on a fresh database, with `psql -v ON_ERROR_STOP=1`. Any failed
-- check raises an exception, so psql exits non-zero.
--
-- This test uses short synthetic text. The real entries are checked by
-- lore_seed.test.sql against supabase/seeds/lore_entries.sql.

\set ON_ERROR_STOP on
\set QUIET on

-- ===== As user A =====
set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', false);

insert into public.planets (id, name) values
  ('11111111-1111-1111-1111-111111111111', 'Lore Planet 1'),
  ('22222222-2222-2222-2222-222222222222', 'Lore Planet 2');

-- user_id is filled by the default auth.uid(); text keeps its newlines
insert into public.lore_entries
  (title, iteration_code, original_text, translation_vi, source, notes, planet_id)
values (
  'Linked entry',
  'TEST-001',
  'Line one
Line two',
  'Dòng một
Dòng hai',
  'test',
  'test',
  '11111111-1111-1111-1111-111111111111'
);

-- optional fields may be NULL
insert into public.lore_entries (title, original_text) values ('Minimal entry', 'Some text');

do $$
declare r record;
begin
  select * into r from public.lore_entries where title = 'Linked entry';
  if r.user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     and r.planet_id = '11111111-1111-1111-1111-111111111111'
     and r.iteration_code = 'TEST-001'
     and array_length(string_to_array(r.original_text, E'\n'), 1) = 2
     and array_length(string_to_array(r.translation_vi, E'\n'), 1) = 2 then
    raise notice 'PASS: full entry inserted (default user_id, multi-line text preserved)';
  else
    raise exception 'FAIL: unexpected row %', r;
  end if;
end $$;

do $$ begin
  begin
    insert into public.lore_entries (original_text) values ('No title');
    raise exception 'FAIL: missing title accepted';
  exception when not_null_violation then
    raise notice 'PASS: title is required';
  end;
end $$;

do $$ begin
  begin
    insert into public.lore_entries (title) values ('No text');
    raise exception 'FAIL: missing original_text accepted';
  exception when not_null_violation then
    raise notice 'PASS: original_text is required';
  end;
end $$;

do $$ begin
  begin
    insert into public.lore_entries (user_id, title, original_text)
    values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Spoofed', 'x');
    raise exception 'FAIL: A inserted a row owned by B';
  exception when insufficient_privilege then
    raise notice 'PASS: RLS blocks inserting a row for another user';
  end;
end $$;

-- updated_at trigger (see corvette_parts.test.sql for why this comparison works)
do $$
declare before_ts timestamptz; after_ts timestamptz;
begin
  select updated_at into before_ts from public.lore_entries where title = 'Minimal entry';
  update public.lore_entries set notes = 'x' where title = 'Minimal entry';
  select updated_at into after_ts from public.lore_entries where title = 'Minimal entry';
  if after_ts > before_ts then
    raise notice 'PASS: updated_at is bumped on update';
  else
    raise exception 'FAIL: updated_at not bumped (% -> %)', before_ts, after_ts;
  end if;
end $$;

-- ON DELETE SET NULL: deleting the planet keeps the lore entry
delete from public.planets where id = '11111111-1111-1111-1111-111111111111';
do $$
declare r record;
begin
  select * into r from public.lore_entries where title = 'Linked entry';
  if r.id is not null and r.planet_id is null then
    raise notice 'PASS: deleting the planet keeps the entry and clears planet_id';
  else
    raise exception 'FAIL: entry missing or planet_id not cleared: %', r;
  end if;
end $$;

-- ===== As user B =====
select set_config('request.jwt.claim.sub', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', false);

do $$
declare n int; u int; d int;
begin
  select count(*) into n from public.lore_entries;
  if n <> 0 then raise exception 'FAIL: B sees % of A rows', n; end if;
  update public.lore_entries set notes = 'hijack';
  get diagnostics u = row_count;
  delete from public.lore_entries;
  get diagnostics d = row_count;
  if u <> 0 or d <> 0 then raise exception 'FAIL: B updated % / deleted % of A rows', u, d; end if;
  raise notice 'PASS: user B cannot select, update or delete user A rows';
end $$;

-- B must not link an entry to a planet owned by A
do $$ begin
  begin
    insert into public.lore_entries (title, original_text, planet_id)
    values ('Cross-user planet', 'x', '22222222-2222-2222-2222-222222222222');
    raise exception 'FAIL: B linked an entry to A planet';
  exception when insufficient_privilege then
    raise notice 'PASS: RLS blocks linking an entry to another user planet';
  end;
end $$;

-- ===== Unauthenticated (anon) =====
reset role;
set role anon;
select set_config('request.jwt.claim.sub', '', false);
do $$
declare n int;
begin
  select count(*) into n from public.lore_entries;
  if n <> 0 then raise exception 'FAIL: anon sees % rows', n; end if;
  begin
    insert into public.lore_entries (title, original_text) values ('Anon', 'x');
    raise exception 'FAIL: anon inserted a row';
  exception when insufficient_privilege or not_null_violation then
    raise notice 'PASS: anon sees 0 rows and cannot insert';
  end;
end $$;

reset role;
