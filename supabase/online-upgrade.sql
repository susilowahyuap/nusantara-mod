-- Jalankan setelah setup.sql untuk upload gambar dan pencatatan klik publik.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'mod-images',
  'mod-images',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Public reads mod images" on storage.objects;
create policy "Public reads mod images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'mod-images');

drop policy if exists "Admins upload mod images" on storage.objects;
create policy "Admins upload mod images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'mod-images' and public.is_admin());

drop policy if exists "Admins update mod images" on storage.objects;
create policy "Admins update mod images"
on storage.objects for update
to authenticated
using (bucket_id = 'mod-images' and public.is_admin())
with check (bucket_id = 'mod-images' and public.is_admin());

drop policy if exists "Admins delete mod images" on storage.objects;
create policy "Admins delete mod images"
on storage.objects for delete
to authenticated
using (bucket_id = 'mod-images' and public.is_admin());

create or replace function public.increment_mod_clicks(mod_id text)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.mods
  set clicks = clicks + 1
  where id = mod_id and active = true;
$$;

revoke all on function public.increment_mod_clicks(text) from public;
grant execute on function public.increment_mod_clicks(text) to anon, authenticated;

-- Isi katalog awal. Mod yang sudah ada tidak akan ditimpa.
insert into public.mods
  (id, title, creator, category, platform, version, size, description, download_url, youtube_url, image_url, rating, featured, active, clicks)
values
  ('nm-001','Jejak Nusantara','Nusantara Mod','Adventure','PC','v2.4','1.2 GB','Ekspansi peta tropis, misi eksplorasi, dan paket tekstur bernuansa kepulauan. Cocok untuk pemain yang ingin menjelajahi area baru dengan suasana Indonesia.','https://example.com','','',4.9,true,true,128),
  ('nm-002','Street Legends ID','Nusantara Mod','Racing','PC','v1.8','780 MB','Paket kendaraan, livery lokal, dan suasana balap malam kota Indonesia dengan pencahayaan yang sudah disesuaikan.','https://example.com','','',4.8,false,true,93),
  ('nm-003','Rimba Terakhir','Nusantara Mod','Survival','Android','v1.2','420 MB','Mod survival hutan hujan dengan cuaca dinamis, crafting yang diperluas, dan tantangan eksplorasi baru.','https://example.com','','',4.7,false,true,76),
  ('nm-004','Angkot Simulator+','Nusantara Mod','Simulator','PC','v3.1','2.1 GB','Rute baru, suasana terminal, radio lokal, dan peningkatan detail kendaraan untuk pengalaman berkendara yang lebih hidup.','https://example.com','','',4.9,false,true,164),
  ('nm-005','Archipelago UI Pack','Nusantara Mod','Utility','Multi','v1.0','85 MB','Antarmuka bersih dengan ikon, peta mini, dan tema warna terinspirasi maritim yang tetap ringan digunakan.','https://example.com','','',4.6,false,true,51),
  ('nm-006','Sawah Realism','Nusantara Mod','Simulator','PC','v2.0','640 MB','Tekstur lahan, sistem musim, dan peralatan pertanian untuk simulasi yang lebih hidup dan detail.','https://example.com','','',4.8,false,true,89),
  ('nm-007','Merapi Expedition','Nusantara Mod','Adventure','PC','v1.4','970 MB','Jalur pendakian baru, siklus cuaca, dan mode foto untuk petualangan pegunungan.','https://example.com','','',4.7,false,true,44),
  ('nm-008','Kota Hujan Traffic','Nusantara Mod','Simulator','Android','v1.1','310 MB','Peningkatan lalu lintas, cuaca hujan, dan pencahayaan jalan yang lebih realistis.','https://example.com','','',4.5,false,true,32),
  ('nm-009','Garuda Performance','Nusantara Mod','Utility','PC','v2.2','32 MB','Preset performa ringan untuk membantu permainan berjalan lebih stabil pada perangkat menengah.','https://example.com','','',4.6,false,true,108)
on conflict (id) do nothing;
