-- Nusantara Mod - struktur database Supabase
-- Aman dijalankan ulang jika proses sebelumnya terputus.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.admin_users
    where user_id = auth.uid()
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

create table if not exists public.mods (
  id text primary key,
  title text not null,
  creator text not null default 'Nusantara Mod',
  category text not null default 'Lainnya',
  platform text not null default 'Android',
  version text not null default '-',
  size text not null default '-',
  description text not null default '',
  details text not null default '',
  install_instructions text not null default '',
  download_label text not null default 'File utama',
  download_url text not null default '',
  download_links jsonb not null default '[]'::jsonb,
  youtube_url text not null default '',
  image_url text not null default '',
  rating numeric(2,1) not null default 0 check (rating >= 0 and rating <= 5),
  featured boolean not null default false,
  active boolean not null default true,
  clicks bigint not null default 0 check (clicks >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.mods
add column if not exists download_links jsonb not null default '[]'::jsonb;

alter table public.mods
add column if not exists details text not null default '';

alter table public.mods
add column if not exists install_instructions text not null default '';

alter table public.mods
add column if not exists download_label text not null default 'File utama';

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'mods_download_links_array_check'
      and conrelid = 'public.mods'::regclass
  ) then
    alter table public.mods
      add constraint mods_download_links_array_check
      check (jsonb_typeof(download_links) = 'array');
  end if;
end
$$;

create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  creator text not null,
  title text not null,
  game text not null default '',
  category text not null default 'Lainnya',
  platform text not null default 'Android',
  version text not null default '-',
  size text not null default '-',
  description text not null,
  image_url text not null default '',
  youtube_url text not null default '',
  download_url text not null default '',
  contact text not null default '',
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.settings (
  id text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.visitor_presence (
  session_id uuid primary key,
  last_seen timestamptz not null default now()
);

create index if not exists visitor_presence_last_seen_idx
on public.visitor_presence (last_seen desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists mods_set_updated_at on public.mods;
create trigger mods_set_updated_at
before update on public.mods
for each row execute function public.set_updated_at();

drop trigger if exists submissions_set_updated_at on public.submissions;
create trigger submissions_set_updated_at
before update on public.submissions
for each row execute function public.set_updated_at();

drop trigger if exists settings_set_updated_at on public.settings;
create trigger settings_set_updated_at
before update on public.settings
for each row execute function public.set_updated_at();

alter table public.admin_users enable row level security;
alter table public.mods enable row level security;
alter table public.submissions enable row level security;
alter table public.settings enable row level security;
alter table public.visitor_presence enable row level security;

revoke all on public.admin_users from anon, authenticated;
revoke all on public.mods from anon, authenticated;
revoke all on public.submissions from anon, authenticated;
revoke all on public.settings from anon, authenticated;
revoke all on public.visitor_presence from anon, authenticated;

grant select on public.admin_users to authenticated;
grant select on public.mods to anon, authenticated;
grant insert, update, delete on public.mods to authenticated;
grant insert on public.submissions to anon, authenticated;
grant select, update, delete on public.submissions to authenticated;
grant select on public.settings to anon, authenticated;
grant insert, update, delete on public.settings to authenticated;

drop policy if exists "Public reads active mods" on public.mods;
create policy "Public reads active mods"
on public.mods for select
to anon, authenticated
using (active or public.is_admin());

drop policy if exists "Admins create mods" on public.mods;
create policy "Admins create mods"
on public.mods for insert
to authenticated
with check (public.is_admin());

drop policy if exists "Admins update mods" on public.mods;
create policy "Admins update mods"
on public.mods for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins delete mods" on public.mods;
create policy "Admins delete mods"
on public.mods for delete
to authenticated
using (public.is_admin());

drop policy if exists "Visitors submit pending mods" on public.submissions;
create policy "Visitors submit pending mods"
on public.submissions for insert
to anon, authenticated
with check (status = 'pending');

drop policy if exists "Admins read submissions" on public.submissions;
create policy "Admins read submissions"
on public.submissions for select
to authenticated
using (public.is_admin());

drop policy if exists "Admins update submissions" on public.submissions;
create policy "Admins update submissions"
on public.submissions for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins delete submissions" on public.submissions;
create policy "Admins delete submissions"
on public.submissions for delete
to authenticated
using (public.is_admin());

drop policy if exists "Visitors read public settings" on public.settings;
create policy "Visitors read public settings"
on public.settings for select
to anon, authenticated
using (true);

drop policy if exists "Admins create settings" on public.settings;
create policy "Admins create settings"
on public.settings for insert
to authenticated
with check (public.is_admin());

drop policy if exists "Admins update settings" on public.settings;
create policy "Admins update settings"
on public.settings for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins delete settings" on public.settings;
create policy "Admins delete settings"
on public.settings for delete
to authenticated
using (public.is_admin());

drop policy if exists "Users read own admin membership" on public.admin_users;
create policy "Users read own admin membership"
on public.admin_users for select
to authenticated
using (user_id = auth.uid());

insert into public.settings (id, value)
values (
  'global',
  '{"ads":{"left":{"enabled":false},"right":{"enabled":false},"top":{"enabled":false},"bottom":{"enabled":false},"inline":{"enabled":false}}}'::jsonb
)
on conflict (id) do nothing;

-- Penyimpanan publik untuk gambar mod; hanya admin yang dapat menulis.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('mod-images', 'mod-images', true, 10485760, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Public reads mod images" on storage.objects;
create policy "Public reads mod images" on storage.objects for select to anon, authenticated
using (bucket_id = 'mod-images');

drop policy if exists "Admins upload mod images" on storage.objects;
create policy "Admins upload mod images" on storage.objects for insert to authenticated
with check (bucket_id = 'mod-images' and public.is_admin());

drop policy if exists "Admins update mod images" on storage.objects;
create policy "Admins update mod images" on storage.objects for update to authenticated
using (bucket_id = 'mod-images' and public.is_admin())
with check (bucket_id = 'mod-images' and public.is_admin());

drop policy if exists "Admins delete mod images" on storage.objects;
create policy "Admins delete mod images" on storage.objects for delete to authenticated
using (bucket_id = 'mod-images' and public.is_admin());

create or replace function public.increment_mod_clicks(mod_id text)
returns void language sql security definer set search_path = ''
as $$
  update public.mods set clicks = clicks + 1 where id = mod_id and active = true;
$$;

revoke all on function public.increment_mod_clicks(text) from public;
grant execute on function public.increment_mod_clicks(text) to anon, authenticated;

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
