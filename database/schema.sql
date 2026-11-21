-- IMCCD starter database. Run this in Supabase SQL Editor.
create extension if not exists pgcrypto;

do $$ begin
  create type public.app_role as enum ('admin', 'manager', 'viewer');
exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role public.app_role not null default 'viewer',
  created_at timestamptz not null default now()
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  phone text,
  address text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_no bigint not null unique,
  order_date date not null,
  customer_id uuid not null references public.customers(id),
  quantity integer not null check (quantity > 0),
  size text,
  ply numeric(5,2),
  paper_color text,
  paper_name text,
  machine text,
  produced_qty integer not null default 0 check (produced_qty >= 0),
  dispatched_qty integer not null default 0 check (dispatched_qty >= 0),
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint dispatched_not_more_than_produced check (dispatched_qty <= produced_qty)
);

create index if not exists orders_date_idx on public.orders(order_date desc);
create index if not exists orders_customer_idx on public.orders(customer_id);

create or replace function public.current_user_role()
returns public.app_role
language sql stable security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

alter table public.profiles enable row level security;
alter table public.customers enable row level security;
alter table public.orders enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles
for select to authenticated using (id = auth.uid() or public.current_user_role() = 'admin');

drop policy if exists "Admins manage profiles" on public.profiles;
create policy "Admins manage profiles" on public.profiles
for all to authenticated using (public.current_user_role() = 'admin')
with check (public.current_user_role() = 'admin');

drop policy if exists "Signed-in users read customers" on public.customers;
create policy "Signed-in users read customers" on public.customers
for select to authenticated using (true);

drop policy if exists "Managers and admins write customers" on public.customers;
create policy "Managers and admins write customers" on public.customers
for all to authenticated using (public.current_user_role() in ('admin','manager'))
with check (public.current_user_role() in ('admin','manager'));

drop policy if exists "Signed-in users read orders" on public.orders;
create policy "Signed-in users read orders" on public.orders
for select to authenticated using (true);

drop policy if exists "Managers and admins write orders" on public.orders;
create policy "Managers and admins write orders" on public.orders
for all to authenticated using (public.current_user_role() in ('admin','manager'))
with check (public.current_user_role() in ('admin','manager'));

-- Realtime publication for live order/customer refresh.
do $$ begin
  alter publication supabase_realtime add table public.orders;
exception when duplicate_object then null; when others then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.customers;
exception when duplicate_object then null; when others then null; end $$;

-- After creating your first user in Supabase Authentication > Users,
-- replace THE_AUTH_USER_UUID below with that user's UUID and run:
-- insert into public.profiles (id, full_name, role)
-- values ('THE_AUTH_USER_UUID', 'IMCCD Admin', 'admin')
-- on conflict (id) do update set role = 'admin';
