# Nusantara Mod

Portal katalog mod dan game komunitas Indonesia. Frontend dibuat dengan HTML, CSS, dan JavaScript, sedangkan database, autentikasi, komentar, rating, serta penyimpanan gambar menggunakan Supabase.

## Struktur

- `dist/` — website yang dipublikasikan ke GitHub Pages
- `supabase/` — skema dan migrasi database
- `.github/workflows/pages.yml` — publikasi otomatis GitHub Pages

## Menjalankan secara lokal

Sajikan folder `dist` menggunakan server HTTP lokal, lalu buka `index.html` melalui alamat server tersebut.

## Keamanan

Jangan menyimpan password, Client Secret OAuth, service-role key Supabase, atau token pribadi di repositori. Publishable key Supabase pada frontend memang dirancang untuk penggunaan publik dan tetap dilindungi oleh Row Level Security.

