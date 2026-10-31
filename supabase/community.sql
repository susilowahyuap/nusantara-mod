-- Nusantara Mod: akun komunitas, komentar, dan rating per mod.
-- Aman dijalankan ulang.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Pengguna',
  avatar_url text not null default '',
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      nullif(new.raw_user_meta_data ->> 'name', ''),
      nullif(split_part(new.email, '@', 1), ''),
      'Pengguna'
    ),
    coalesce(nullif(new.raw_user_meta_data ->> 'avatar_url', ''), '')
  )
  on conflict (id) do update
  set display_name = excluded.display_name,
      avatar_url = excluded.avatar_url;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert or update of raw_user_meta_data on auth.users
for each row execute function public.handle_new_user();

insert into public.profiles (id, display_name, avatar_url)
select
  id,
  coalesce(
    nullif(raw_user_meta_data ->> 'full_name', ''),
    nullif(raw_user_meta_data ->> 'name', ''),
    nullif(split_part(email, '@', 1), ''),
    'Pengguna'
  ),
  coalesce(nullif(raw_user_meta_data ->> 'avatar_url', ''), '')
from auth.users
on conflict (id) do nothing;

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  mod_id text not null references public.mods(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 2 and 800),
  created_at timestamptz not null default now()
);

create index if not exists comments_mod_created_idx
on public.comments (mod_id, created_at desc);

create table if not exists public.ratings (
  mod_id text not null references public.mods(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  value smallint not null check (value between 1 and 5),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (mod_id, user_id)
);

drop trigger if exists ratings_set_updated_at on public.ratings;
create trigger ratings_set_updated_at
before update on public.ratings
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.comments enable row level security;
alter table public.ratings enable row level security;

revoke all on public.profiles from anon, authenticated;
revoke all on public.comments from anon, authenticated;
revoke all on public.ratings from anon, authenticated;

grant select on public.profiles to anon, authenticated;
grant select on public.comments to anon, authenticated;
grant insert, delete on public.comments to authenticated;
grant select on public.ratings to anon, authenticated;
grant insert, update, delete on public.ratings to authenticated;

drop policy if exists "Everyone reads profiles" on public.profiles;
create policy "Everyone reads profiles"
on public.profiles for select
to anon, authenticated
using (true);

drop policy if exists "Everyone reads comments" on public.comments;
create policy "Everyone reads comments"
on public.comments for select
to anon, authenticated
using (true);

drop policy if exists "Users create own comments" on public.comments;
create policy "Users create own comments"
on public.comments for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users or admins delete comments" on public.comments;
create policy "Users or admins delete comments"
on public.comments for delete
to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "Everyone reads ratings" on public.ratings;
create policy "Everyone reads ratings"
on public.ratings for select
to anon, authenticated
using (true);

drop policy if exists "Users create own rating" on public.ratings;
create policy "Users create own rating"
on public.ratings for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users update own rating" on public.ratings;
create policy "Users update own rating"
on public.ratings for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Users delete own rating" on public.ratings;
create policy "Users delete own rating"
on public.ratings for delete
to authenticated
using (user_id = auth.uid());
