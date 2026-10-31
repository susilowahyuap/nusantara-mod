# Nusantara Mod

Portal katalog mod dan game komunitas Indonesia. Frontend dibuat dengan HTML, CSS, dan JavaScript, sedangkan database, autentikasi, komentar, rating, serta penyimpanan gambar menggunakan Supabase.

## Struktur

- `dist/` — website yang dipublikasikan ke GitHub Pages
- `supabase/` — skema dan migrasi database
- `.github/workflows/pages.yml` — publikasi otomatis GitHub Pages

## Menjalankan secara lokal

Sajikan folder `dist` menggunakan server HTTP lokal, lalu buka `index.html` melalui alamat server tersebut.

## Pembaruan komentar bertingkat

Untuk proyek Supabase yang sudah aktif, jalankan `supabase/threaded-comments-upgrade.sql` melalui SQL Editor. Instalasi baru cukup menjalankan `supabase/setup.sql`, lalu `supabase/community.sql`. Pengguna harus login melalui Google atau tautan email sebelum dapat memberi rating, menulis komentar, atau membalas komentar.

Di Supabase Auth, tambahkan URL GitHub Pages produksi dan URL lokal pengembangan ke daftar Redirect URLs agar alur OAuth dan magic link dapat kembali ke halaman detail yang benar.

## Deployment

Workflow `.github/workflows/pages.yml` memvalidasi berkas inti dan dukungan `parent_id`, kemudian memublikasikan isi `dist/` pada setiap push ke branch `main`. Jalankan workflow secara manual melalui tab Actions bila hanya ingin mengulang deployment tanpa commit baru.

## Keamanan

Jangan menyimpan password, Client Secret OAuth, service-role key Supabase, atau token pribadi di repositori. Publishable key Supabase pada frontend memang dirancang untuk penggunaan publik dan tetap dilindungi oleh Row Level Security.

