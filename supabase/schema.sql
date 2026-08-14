-- AgriLink production database
create extension if not exists pgcrypto;

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null check (role in ('farmer','buyer','admin')),
  phone text,
  location text,
  created_at timestamptz default now()
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  farmer_id uuid not null references profiles(id) on delete cascade,
  name text not null,
  category text not null,
  description text,
  price numeric(12,2) not null check (price >= 0),
  unit text not null,
  quantity numeric(12,2) not null check (quantity >= 0),
  location text not null,
  image_url text,
  status text not null default 'available' check (status in ('available','sold','paused')),
  created_at timestamptz default now()
);

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references profiles(id),
  farmer_id uuid not null references profiles(id),
  product_id uuid not null references products(id),
  quantity numeric(12,2) not null check (quantity > 0),
  total_amount numeric(12,2) not null check (total_amount >= 0),
  platform_fee numeric(12,2) not null default 0 check (platform_fee >= 0),
  status text not null default 'pending' check (status in ('pending','accepted','completed','cancelled')),
  created_at timestamptz default now()
);

create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  order_id uuid unique not null references orders(id) on delete cascade,
  buyer_id uuid not null references profiles(id),
  farmer_id uuid not null references profiles(id),
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz default now()
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references profiles(id),
  receiver_id uuid not null references profiles(id),
  product_id uuid references products(id) on delete set null,
  body text not null,
  created_at timestamptz default now()
);

create index if not exists products_location_idx on products(location);
create index if not exists products_category_idx on products(category);
create index if not exists orders_buyer_idx on orders(buyer_id);
create index if not exists orders_farmer_idx on orders(farmer_id);
create index if not exists messages_sender_receiver_idx on messages(sender_id,receiver_id,created_at);

-- Create a profile automatically after signup using signup metadata.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role, phone, location)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name','AgriLink User'),
    case when new.raw_user_meta_data->>'role' in ('farmer','buyer') then new.raw_user_meta_data->>'role' else 'buyer' end,
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'location'
  ) on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Row Level Security: users can read public marketplace data, but only owners can modify their own records.
alter table profiles enable row level security;
alter table products enable row level security;
alter table orders enable row level security;
alter table reviews enable row level security;
alter table messages enable row level security;

drop policy if exists "profiles are publicly readable" on profiles;
create policy "profiles are publicly readable" on profiles for select using (true);
drop policy if exists "users update own profile" on profiles;
create policy "users update own profile" on profiles for update using (auth.uid()=id) with check (auth.uid()=id);

drop policy if exists "available products are publicly readable" on products;
create policy "available products are publicly readable" on products for select using (status='available' or farmer_id=auth.uid());
drop policy if exists "farmers create own products" on products;
create policy "farmers create own products" on products for insert with check (farmer_id=auth.uid() and exists(select 1 from profiles where id=auth.uid() and role='farmer'));
drop policy if exists "farmers update own products" on products;
create policy "farmers update own products" on products for update using (farmer_id=auth.uid()) with check (farmer_id=auth.uid());
drop policy if exists "farmers delete own products" on products;
create policy "farmers delete own products" on products for delete using (farmer_id=auth.uid());

-- Buyers can create orders for themselves; participants can read their orders.
drop policy if exists "participants read orders" on orders;
create policy "participants read orders" on orders for select using (buyer_id=auth.uid() or farmer_id=auth.uid());
drop policy if exists "buyers create orders" on orders;
create policy "buyers create orders" on orders for insert with check (buyer_id=auth.uid() and exists(select 1 from profiles where id=auth.uid() and role='buyer'));
drop policy if exists "participants update orders" on orders;
create policy "participants update orders" on orders for update using (buyer_id=auth.uid() or farmer_id=auth.uid());

drop policy if exists "read reviews" on reviews;
create policy "read reviews" on reviews for select using (true);
drop policy if exists "buyers create reviews" on reviews;
create policy "buyers create reviews" on reviews for insert with check (buyer_id=auth.uid());

drop policy if exists "participants read messages" on messages;
create policy "participants read messages" on messages for select using (sender_id=auth.uid() or receiver_id=auth.uid());
drop policy if exists "users send messages" on messages;
create policy "users send messages" on messages for insert with check (sender_id=auth.uid());

-- Planned marketplace commission: 3% of successful transactions.
-- Payment processing and commission calculation must ultimately run server-side.
