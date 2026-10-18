-- Laboratorio 5: tabla de perfiles. Una fila por usuario de Auth, con el mismo id.
-- Se puede correr sobre un proyecto nuevo o sobre uno donde ya exista la tabla
-- de las migraciones de clase (con la columna email): la deja igual al lab.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  full_name text not null
);

-- La versión de clase guardaba el correo; el lab no lo usa (ya vive en Auth).
alter table public.profiles drop column if exists email;

grant select, insert, update on public.profiles to authenticated;
