-- Nusantara Mod: konten detail terpisah dan statistik pengunjung aktif.
-- Jalankan pada SQL Editor Supabase sebelum deploy frontend baru.
-- Aman dijalankan ulang.

alter table public.mods
add column if not exists details text not null default '';

create table if not exists public.visitor_presence (
  session_id uuid primary key,
  last_seen timestamptz not null default now()
);

create index if not exists visitor_presence_last_seen_idx
on public.visitor_presence (last_seen desc);

alter table public.visitor_presence enable row level security;
revoke all on public.visitor_presence from anon, authenticated;

create or replace function public.record_visitor_presence(p_session_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.visitor_presence (session_id, last_seen)
  values (p_session_id, now())
  on conflict (session_id) do update
  set last_seen = excluded.last_seen;

  delete from public.visitor_presence
  where last_seen < now() - interval '7 days';
end;
$$;

revoke all on function public.record_visitor_presence(uuid) from public;
grant execute on function public.record_visitor_presence(uuid) to anon, authenticated;

create or replace function public.recent_visitor_count(window_minutes integer default 120)
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when public.is_admin() then (
      select count(*)::bigint
      from public.visitor_presence
      where last_seen >= now() - (greatest(5, least(window_minutes, 1440)) || ' minutes')::interval
    )
    else 0::bigint
  end;
$$;

revoke all on function public.recent_visitor_count(integer) from public;
grant execute on function public.recent_visitor_count(integer) to authenticated;
