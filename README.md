# Ana Carvalho — Ficha de Anamnese

Sistema React/Vite com formulário mobile-first e área administrativa protegida por Supabase Auth + RLS.

## 1. Configurar Supabase

1. Crie um projeto no Supabase.
2. Abra **SQL Editor** e execute `supabase/schema.sql`.
3. Em **Authentication > Users**, crie um usuário administrativo com um e-mail interno (ex.: `anacarvalhoadmin06@admin.anacarvalho.local`) e defina a senha administrativa escolhida pela Ana. Se o projeto exigir confirmação, marque o usuário como confirmado.
4. Copie o UUID desse usuário e execute:

```sql
insert into public.admin_profiles (id, username)
values ('UUID_DO_USUARIO_AUTH', 'anacarvalhoadmin06');
```

5. Copie `.env.example` para `.env.local` e preencha `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY`.

A senha não fica armazenada no código nem na tabela `admin_profiles`; ela é gerenciada pelo Supabase Auth.

## 2. Rodar

```bash
npm install
npm run dev
```

## 3. Deploy Vercel

- Framework: Vite
- Build: `npm run build`
- Output: `dist`
- Node 20+
- Configure as mesmas duas variáveis de ambiente no projeto Vercel.

## Rotas

- `/` — ficha pública
- `/admin` — área restrita
