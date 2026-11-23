# Painel SST

Painel da equipe de Segurança do Trabalho. Cada TST lança as atividades do dia, e o painel mostra os indicadores da semana e do mês por técnico e para a equipe.

- **Página:** `index.html`, publicada no GitHub Pages.
- **Dados:** ficam no Supabase. Para ver ou lançar, é preciso entrar com e-mail e senha.

## Arquivos

| Arquivo | Para que serve |
|---|---|
| `index.html` | O painel |
| `config.js` | URL e chave pública do seu projeto Supabase |
| `supabase.sql` | Cria as tabelas e as regras de acesso no Supabase |

## Passo a passo

### 1. Criar o banco no Supabase
1. Crie uma conta gratuita em https://supabase.com e clique em **New project**. Escolha a região **South America (São Paulo)**.
2. No menu da esquerda, abra **SQL Editor**, cole todo o conteúdo de `supabase.sql` e clique em **Run**.

### 2. Cadastrar a equipe
1. Abra **Authentication → Sign In / Providers → Email** e desligue **Allow new users to sign up**. Assim, ninguém de fora consegue criar conta.
2. Abra **Authentication → Users → Add user → Create new user**. Cadastre você e cada um dos TSTs com e-mail e senha, deixando marcado **Auto Confirm User**.
3. Para poder alterar as metas, volte ao **SQL Editor** e rode a linha abaixo, trocando pelo seu e-mail:
   ```sql
   insert into public.admins (user_id) select id from auth.users where email = 'seu-email@exemplo.com';
   ```

### 3. Ligar o painel ao banco
1. Abra **Project Settings → API**. Copie a **Project URL** e a chave **anon public**.
2. Cole as duas no arquivo `config.js`, entre as aspas.

A chave *anon* foi feita para ficar visível no site. Os dados são protegidos pelo login e pelas regras criadas no `supabase.sql`.

### 4. Publicar no GitHub Pages
1. Em https://github.com, clique em **New repository**, dê um nome (por exemplo, `painel-sst`) e marque **Public**. No plano gratuito, o GitHub Pages só funciona com repositório público. Os dados continuam protegidos, porque ficam no Supabase.
2. No repositório criado, clique em **Add file → Upload files**. Arraste os arquivos `index.html`, `config.js`, `supabase.sql` e `README.md` e clique em **Commit changes**.
3. Abra **Settings → Pages**. Em *Source*, escolha **Deploy from a branch**, depois **main** e **/(root)**, e clique em **Save**.
4. Em cerca de 1 minuto, o painel fica disponível em `https://SEU-USUARIO.github.io/painel-sst/`.

## Uso no dia a dia
- **Lançamento diário:** cada TST escolhe a data e o próprio nome e lança as atividades. Um novo lançamento no mesmo dia edita o anterior.
- **Painel:** mostra os indicadores da semana ou do mês, da equipe inteira ou de um TST.
- **Registros:** lista os lançamentos do período, com opções de editar, excluir e baixar CSV.
- **Metas:** guarda as metas semanais por atividade. Só administradores alteram.
- **Senhas:** para trocar a senha de alguém, use **Authentication → Users** no Supabase.
