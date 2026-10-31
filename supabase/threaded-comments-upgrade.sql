-- Nusantara Mod: upgrade komentar datar menjadi balasan bertingkat.
-- Jalankan sekali pada SQL Editor Supabase untuk proyek yang sudah memakai community.sql.
-- Aman dijalankan ulang.

alter table public.comments
add column if not exists parent_id uuid;

create unique index if not exists comments_id_mod_unique_idx
on public.comments (id, mod_id);

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'comments_parent_same_mod_fk'
      and conrelid = 'public.comments'::regclass
  ) then
    alter table public.comments
      add constraint comments_parent_same_mod_fk
      foreign key (parent_id, mod_id)
      references public.comments (id, mod_id)
      on delete cascade;
  end if;
end
$$;

create index if not exists comments_parent_created_idx
on public.comments (parent_id, created_at asc);

-- Kebijakan RLS lama tetap berlaku: hanya pengguna authenticated yang dapat
-- menulis komentar/balasan miliknya; pembaca anonim hanya mendapat SELECT.
