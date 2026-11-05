-- Smoke test for public.corvette_parts (constraints, RLS, updated_at trigger).
-- Run after stub_supabase.sql and schema.sql, on a fresh database, with
-- `psql -v ON_ERROR_STOP=1`. Any failed check raises an exception, so psql
-- exits non-zero.

\set ON_ERROR_STOP on
\set QUIET on

-- ===== As user A =====
set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', false);

-- user_id is filled by the default auth.uid()
insert into public.corvette_parts (name, part_type, part_class, bonus_summary, price_units, source)
values ('Medusa-Class Reactor', 'reactor', 'Medusa', 'Manoeuvrability +6%, Boost +12%', 1750000, 'GTN');
-- price may be NULL
insert into public.corvette_parts (name, part_type) values ('Tractor Beam', 'tractor_beam');

do $$
declare r record;
begin
  select * into r from public.corvette_parts where name = 'Medusa-Class Reactor';
  if r.user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' and r.price_units = 1750000
     and r.part_type = 'reactor' then
    raise notice 'PASS: insert with default user_id and price 1750000';
  else
    raise exception 'FAIL: unexpected row %', r;
  end if;
end $$;

do $$ begin
  begin
    insert into public.corvette_parts (name, part_type) values ('Medusa-Class Reactor', 'reactor');
    raise exception 'FAIL: duplicate (user_id, name) accepted';
  exception when unique_violation then
    raise notice 'PASS: duplicate name rejected for same user';
  end;
end $$;

do $$ begin
  begin
    insert into public.corvette_parts (name, part_type, price_units) values ('Bad Price', 'reactor', -1);
    raise exception 'FAIL: negative price accepted';
  exception when check_violation then
    raise notice 'PASS: negative price rejected';
  end;
end $$;

do $$ begin
  begin
    insert into public.corvette_parts (name) values ('No Type');
    raise exception 'FAIL: missing part_type accepted';
  exception when not_null_violation then
    raise notice 'PASS: part_type is required';
  end;
end $$;

do $$ begin
  begin
    insert into public.corvette_parts (user_id, name, part_type)
    values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Spoofed', 'reactor');
    raise exception 'FAIL: A inserted a row owned by B';
  exception when insufficient_privilege then
    raise notice 'PASS: RLS blocks inserting a row for another user';
  end;
end $$;

-- updated_at trigger. This DO block runs in a later transaction than the
-- insert above, so now() inside it is newer than the stored updated_at; without
-- the trigger the value would stay unchanged.
do $$
declare before_ts timestamptz; after_ts timestamptz;
begin
  select updated_at into before_ts from public.corvette_parts where name = 'Tractor Beam';
  update public.corvette_parts set notes = 'x' where name = 'Tractor Beam';
  select updated_at into after_ts from public.corvette_parts where name = 'Tractor Beam';
  if after_ts > before_ts then
    raise notice 'PASS: updated_at is bumped on update';
  else
    raise exception 'FAIL: updated_at not bumped (% -> %)', before_ts, after_ts;
  end if;
end $$;

-- ===== As user B =====
select set_config('request.jwt.claim.sub', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', false);

do $$
declare n int; u int; d int;
begin
  select count(*) into n from public.corvette_parts;
  if n <> 0 then raise exception 'FAIL: B sees % of A rows', n; end if;
  update public.corvette_parts set notes = 'hijack';
  get diagnostics u = row_count;
  delete from public.corvette_parts;
  get diagnostics d = row_count;
  if u <> 0 or d <> 0 then raise exception 'FAIL: B updated % / deleted % of A rows', u, d; end if;
  raise notice 'PASS: user B cannot select, update or delete user A rows';
end $$;

-- B can reuse the same part name (unique is per user)
insert into public.corvette_parts (name, part_type) values ('Medusa-Class Reactor', 'reactor');
do $$ begin raise notice 'PASS: same part name allowed for a different user'; end $$;

-- ===== Unauthenticated (anon) =====
reset role;
set role anon;
select set_config('request.jwt.claim.sub', '', false);
do $$
declare n int;
begin
  select count(*) into n from public.corvette_parts;
  if n <> 0 then raise exception 'FAIL: anon sees % rows', n; end if;
  begin
    insert into public.corvette_parts (name, part_type) values ('Anon', 'reactor');
    raise exception 'FAIL: anon inserted a row';
  exception when insufficient_privilege or not_null_violation then
    raise notice 'PASS: anon sees 0 rows and cannot insert';
  end;
end $$;

reset role;
