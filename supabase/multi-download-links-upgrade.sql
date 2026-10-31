-- Nusantara Mod: menambahkan beberapa link mod/file pada satu item katalog.
-- Jalankan pada SQL Editor untuk proyek Supabase yang sudah aktif.
-- Aman dijalankan ulang.

alter table public.mods
add column if not exists download_links jsonb not null default '[]'::jsonb;

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
