-- AgriLink production database blueprint
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

-- Planned marketplace commission: 3% of successful transactions.
-- Payment integration should calculate this server-side, not in the browser.
