# Manifesto — Pacote de hospedagem

Site estático (sem build, sem Node). Arquivos:

| Arquivo | Para quê |
|---|---|
| `index.html` | O sistema inteiro |
| `config.js` | (opcional) URL e chave anon do Supabase já preenchidas |
| `vercel.json` | Ajustes para a Vercel |
| `supabase-schema.sql` | Cria a tabela no Supabase |

Login inicial: **adm / 1234** (troque criando outro usuário master em Configurações e removendo o padrão).

## 1) Supabase (banco de dados)
1. Crie um projeto em supabase.com.
2. **SQL Editor → New query**, cole `supabase-schema.sql` e clique **Run**.
3. Em **Project Settings → API**, copie a **Project URL** e a chave **anon / public**.
4. Cole nos campos de `config.js` (vale para todos os computadores) **ou** digite em
   Configurações → Supabase dentro do sistema (vale só para aquele navegador).

> O Supabase aqui é só o banco. Ele não hospeda o site — por isso o site vai na Vercel (ou GTI Hub).

## 2) Vercel
**Pelo painel:** vercel.com → *Add New → Project* → *Import* do repositório Git com estes arquivos
(Framework: **Other**, sem Build Command, Output Directory vazio/raiz).

**Sem Git:** instale a CLI e, dentro desta pasta, rode:
```
npm i -g vercel
vercel --prod
```

## 3) GTI Hub
Basta enviar o conteúdo desta pasta (com `index.html` na **raiz**) como site estático.
Não há build nem servidor. Se a plataforma pedir comando de build, deixe em branco.

## Observações
- Os dados ficam no navegador (localStorage) e, com o Supabase ativo, também na nuvem.
- A política do `supabase-schema.sql` é permissiva: quem tiver a chave anon lê e altera os romaneios.
  Use apenas internamente. Login e senhas do sistema são uma trava básica (não substituem autenticação real).
- Abra sempre por `https://` (site publicado) ou duplo clique no `index.html`; ambos funcionam.
