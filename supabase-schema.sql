-- ============================================================
-- MANIFESTO — Sistema de Romaneio & Alocação de Frota
-- Script COMPLETO do banco no Supabase (pode rodar quantas vezes quiser)
--
-- COMO USAR:
-- 1. Abra seu projeto em https://supabase.com/dashboard
-- 2. Menu lateral → "SQL Editor" → "New query"
-- 3. Cole TODO este arquivo e clique em "Run"
-- 4. No sistema: Configurações → Supabase → cole a URL e a chave
--    anon/public, marque "Usar Supabase" e salve.
--
-- Depois disso o login  adm / 1234  (usuário MASTER) já existe no banco.
-- ============================================================


-- ------------------------------------------------------------
-- 1) ROMANEIOS — cada linha é um romaneio completo (JSON)
-- ------------------------------------------------------------
create table if not exists public.romaneios (
  id        text primary key,          -- ex: ROM-2026-0001
  data      jsonb not null,            -- romaneio completo (dados, itens, veículos, mapa 3D...)
  saved_at  timestamptz not null default now()
);

create index if not exists romaneios_saved_at_idx
  on public.romaneios (saved_at desc);

alter table public.romaneios enable row level security;

drop policy if exists "allow all for anon" on public.romaneios;
create policy "allow all for anon"
  on public.romaneios
  for all
  using (true)
  with check (true);


-- ------------------------------------------------------------
-- 2) USUÁRIOS — login, senha (em hash) e perfil
--    role = 'master'  → acessa Configurações (usuários e Supabase)
--    role = 'user'    → usuário comum
-- ------------------------------------------------------------
create table if not exists public.usuarios (
  login       text primary key,
  senha       text not null,           -- hash SHA-256 com sal (nunca a senha pura)
  role        text not null default 'user',
  created_at  timestamptz not null default now()
);

-- garante a coluna "role" mesmo se a tabela já existia sem ela
alter table public.usuarios
  add column if not exists role text not null default 'user';

-- aceita somente os dois perfis
alter table public.usuarios drop constraint if exists usuarios_role_check;
alter table public.usuarios
  add constraint usuarios_role_check check (role in ('master', 'user'));

alter table public.usuarios enable row level security;

drop policy if exists "allow all for anon" on public.usuarios;
create policy "allow all for anon"
  on public.usuarios
  for all
  using (true)
  with check (true);


-- ------------------------------------------------------------
-- 3) USUÁRIO MASTER INICIAL:  login adm  /  senha 1234
--    (a senha vai gravada em hash SHA-256, não em texto puro)
--    Rodar este script de novo restaura adm/1234 como master.
-- ------------------------------------------------------------
insert into public.usuarios (login, senha, role)
values ('adm', 'sha256$7c1e9a4b52d03f86$637eb1291dee4c1c8d223a8f40a6a00fab2b86d327e687ae4a2b4fdbe9061c0b', 'master')
on conflict (login) do update
  set senha = excluded.senha,
      role  = 'master';


-- ------------------------------------------------------------
-- AVISO DE SEGURANÇA
-- As políticas acima liberam leitura/escrita para quem tiver a chave
-- anon do projeto (inclusive ler os hashes dos usuários). Use apenas
-- em ambiente interno/confiável e troque a senha 1234 depois do
-- primeiro acesso (crie outro master em Configurações).
-- ------------------------------------------------------------
