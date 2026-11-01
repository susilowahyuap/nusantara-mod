-- Nusantara Mod: rincian, inventaris file, dan panduan instalasi.
-- Salin seluruh isi file ini ke SQL Editor Supabase, lalu klik Run.
-- Aman dijalankan ulang.

alter table public.mods
add column if not exists details text not null default '';

alter table public.mods
add column if not exists download_label text not null default 'File utama';

alter table public.mods
add column if not exists install_instructions text not null default '';
