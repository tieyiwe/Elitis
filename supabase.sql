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

-- 4. Commandes confirmées par l'hôtesse (statut visible par le voyageur)
create table if not exists public.orders (
  bus        text not null,
  day        date not null,
  code       text not null,
  seat       int  not null,
  items      text not null,
  total      int  not null default 0,
  status     text not null check (status in ('recue','servie')),
  updated_at timestamptz not null default now(),
  primary key (bus, day, code)
);
alter table public.orders enable row level security;   -- aucune policy : accès uniquement via les fonctions ci-dessous

-- L'hôtesse (avec le PIN) confirme / met à jour une commande
create or replace function public.set_order(p_pin text, p_bus text, p_day date, p_code text, p_seat int, p_items text, p_total int, p_status text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_pin is null or p_pin is distinct from (select v from public.app_secrets where k = 'hostess_pin') then
    raise exception 'PIN invalide';
  end if;
  insert into public.orders (bus, day, code, seat, items, total, status, updated_at)
  values (left(p_bus,20), p_day, left(p_code,8), p_seat, left(p_items,500), coalesce(p_total,0), p_status, now())
  on conflict (bus, day, code) do update
    set seat = excluded.seat, items = excluded.items, total = excluded.total, status = excluded.status, updated_at = now();
end $$;
revoke all on function public.set_order(text, text, date, text, int, text, int, text) from public;
grant execute on function public.set_order(text, text, date, text, int, text, int, text) to anon, authenticated;

-- Le voyageur consulte le statut de SA commande (code + siège requis)
create or replace function public.get_order_status(p_bus text, p_day date, p_code text, p_seat int)
returns json language sql security definer set search_path = public stable as $$
  select json_build_object('status', status, 'items', items, 'updated_at', updated_at)
  from public.orders where bus = p_bus and day = p_day and code = p_code and seat = p_seat;
$$;
revoke all on function public.get_order_status(text, date, text, int) from public;
grant execute on function public.get_order_status(text, date, text, int) to anon, authenticated;
