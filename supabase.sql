-- Painel SST · estrutura do banco no Supabase
-- Cole tudo no SQL Editor do seu projeto Supabase e clique em "Run".

-- Lançamentos: um registro por TST por dia
create table if not exists public.lancamentos (
  data          date        not null,
  tst           text        not null,
  v             jsonb       not null default '{}'::jsonb,
  total         integer     not null default 0 check (total >= 0),
  obs           text        not null default '',
  atualizado_em timestamptz not null default now(),
  atualizado_por uuid       default auth.uid() references auth.users(id) on delete set null,
  primary key (data, tst)
);

-- Configurações (metas semanais)
create table if not exists public.config (
  id            text primary key,
  valor         jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now()
);

-- Quem pode alterar as metas
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.lancamentos enable row level security;
alter table public.config      enable row level security;
alter table public.admins      enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- Qualquer pessoa da equipe com login lê e lança atividades
drop policy if exists "equipe le lancamentos" on public.lancamentos;
drop policy if exists "equipe insere lancamentos" on public.lancamentos;
drop policy if exists "equipe atualiza lancamentos" on public.lancamentos;
drop policy if exists "equipe exclui lancamentos" on public.lancamentos;
create policy "equipe le lancamentos"       on public.lancamentos for select to authenticated using (true);
create policy "equipe insere lancamentos"   on public.lancamentos for insert to authenticated with check (true);
create policy "equipe atualiza lancamentos" on public.lancamentos for update to authenticated using (true) with check (true);
create policy "equipe exclui lancamentos"   on public.lancamentos for delete to authenticated using (true);

-- Todos leem as metas; só administradores alteram
drop policy if exists "equipe le config" on public.config;
drop policy if exists "admin grava config" on public.config;
create policy "equipe le config"   on public.config for select to authenticated using (true);
create policy "admin grava config" on public.config for all    to authenticated using (public.is_admin()) with check (public.is_admin());

-- Cada pessoa só consegue ver se ela mesma é administradora
drop policy if exists "ve o proprio admin" on public.admins;
create policy "ve o proprio admin" on public.admins for select to authenticated using (user_id = auth.uid());

-- Permissões de acesso para quem está logado (projetos novos do Supabase não liberam por padrão)
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.lancamentos to authenticated;
grant select, insert, update, delete on public.config to authenticated;
grant select on public.admins to authenticated;
grant execute on function public.is_admin() to authenticated;

-- Atualização em tempo real no painel
do $$ begin
  begin alter publication supabase_realtime add table public.lancamentos; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.config;      exception when duplicate_object then null; end;
end $$;

-- DEPOIS de criar o seu usuário em Authentication > Users, rode a linha abaixo
-- trocando o e-mail, para poder alterar as metas:
-- insert into public.admins (user_id) select id from auth.users where email = 'seu-email@exemplo.com';
