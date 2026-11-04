-- Elitis Express · Menu à bord : synchronisation du menu du jour
-- À exécuter une fois dans Supabase > SQL Editor > New query > Run

-- 1. Menu du jour par bus (lecture publique)
create table if not exists public.dispo (
  bus        text primary key,
  day        date not null,
  off        text[] not null default '{}',
  updated_at timestamptz not null default now()
);
alter table public.dispo enable row level security;
drop policy if exists "Lecture publique du menu du jour" on public.dispo;
create policy "Lecture publique du menu du jour" on public.dispo for select to anon, authenticated using (true);

-- 2. Code PIN des hôtesses (jamais lisible depuis l'application)
create table if not exists public.app_secrets (k text primary key, v text not null);
alter table public.app_secrets enable row level security;   -- aucune policy : inaccessible depuis l'app
insert into public.app_secrets (k, v) values ('hostess_pin', 'CHANGEZ-MOI')
  on conflict (k) do nothing;
-- Pour changer le PIN plus tard :
-- update public.app_secrets set v = 'NOUVEAU-PIN' where k = 'hostess_pin';

-- 3. Seule l'hôtesse (avec le PIN) peut publier le menu du jour
create or replace function public.set_dispo(p_pin text, p_bus text, p_day date, p_off text[])
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_pin is null or p_pin is distinct from (select v from public.app_secrets where k = 'hostess_pin') then
    raise exception 'PIN invalide';
  end if;
  insert into public.dispo (bus, day, off, updated_at)
  values (left(p_bus, 20), p_day, coalesce(p_off, '{}'), now())
  on conflict (bus) do update set day = excluded.day, off = excluded.off, updated_at = now();
end $$;
revoke all on function public.set_dispo(text, text, date, text[]) from public;
grant execute on function public.set_dispo(text, text, date, text[]) to anon, authenticated;
