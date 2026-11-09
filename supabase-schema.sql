-- ============================================================
-- MANIFESTO — Sistema de Romaneio & Alocação de Frota
-- Script de criação da tabela no Supabase
--
-- COMO USAR:
-- 1. Acesse seu projeto em https://supabase.com/dashboard
-- 2. Vá em "SQL Editor" (menu lateral)
-- 3. Clique em "New query", cole todo este arquivo e clique em "Run"
-- 4. Depois disso, no sistema, vá em Configurações → Supabase,
--    cole a URL do projeto e a chave anon/public, e salve.
-- ============================================================

-- Tabela principal: cada linha é um romaneio completo, guardado
-- como JSON em "data" (mesmo formato que o sistema já usa
-- localmente), o que evita ter que mapear cada campo em colunas
-- separadas e mantém o app simples de manter no futuro.
create table if not exists public.romaneios (
  id         text primary key,        -- ex: ROM-2026-0001
  data       jsonb not null,          -- romaneio completo (projeto, origem, destino, itens, veículos, etc.)
  saved_at   timestamptz not null default now()
);

-- Índice para ordenar rapidamente pelos mais recentes
create index if not exists romaneios_saved_at_idx
  on public.romaneios (saved_at desc);

-- Habilita Row Level Security (obrigatório pelo Supabase para
-- liberar acesso via chave anon de forma explícita)
alter table public.romaneios enable row level security;

-- Política de acesso: libera leitura/escrita/exclusão para quem
-- tiver a chave anon/public do projeto.
--
-- ATENÇÃO — leia antes de usar em produção:
-- Esta política é permissiva (equivalente a "todo mundo com a
-- chave anon pode ler e alterar tudo"). Isso é adequado para uso
-- interno/confiável (ex: apenas a equipe da empresa tem a chave),
-- mas NÃO deve ser usado se o sistema for exposto publicamente na
-- internet sem controle. Se precisar de regras mais restritas
-- (por usuário, por empresa, etc.), isso exige conectar o login
-- do sistema à autenticação do Supabase (auth.uid()) e trocar a
-- condição "using (true)" abaixo por uma regra baseada nisso.
drop policy if exists "allow all for anon" on public.romaneios;
create policy "allow all for anon"
  on public.romaneios
  for all
  using (true)
  with check (true);


-- ============================================================
-- USUÁRIOS DO SISTEMA (login)
-- A coluna "senha" guarda um hash SHA-256 com sal, gerado pelo
-- próprio sistema — nunca a senha em texto puro. O usuário
-- master padrão (adm) é enviado automaticamente no primeiro
-- login com o Supabase ativo, ou pelo botão
-- "Enviar usuários ao Supabase" em Configurações.
--
-- ATENÇÃO: com a política permissiva abaixo, quem tiver a chave
-- anon consegue LER os hashes e alterar usuários. Use só em
-- ambiente interno/confiável e troque a senha padrão (1234).
-- ============================================================
create table if not exists public.usuarios (
  login      text primary key,
  senha      text not null,
  created_at timestamptz not null default now()
);

alter table public.usuarios enable row level security;

drop policy if exists "allow all for anon" on public.usuarios;
create policy "allow all for anon"
  on public.usuarios
  for all
  using (true)
  with check (true);

-- Se a tabela "usuarios" já existia com a coluna de função (role), remova-a.
-- O sistema não usa mais essa coluna: o master é sempre o login "adm".
alter table public.usuarios drop column if exists role;
