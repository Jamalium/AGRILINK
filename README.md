# AgriLink 🌱

A Lesotho-first marketplace connecting farmers with consumers, restaurants, shops and wholesalers.

## Current MVP

- Responsive landing page and mobile-first UI
- Farmer and buyer signup/sign-in
- Supabase profile creation from signup metadata
- Farmer dashboard
- Real farmer product listing flow
- Live marketplace reads from Supabase with demo fallback
- Search and category filters
- Product detail pages
- Database schema with Row Level Security policies
- Planned 3% marketplace commission field on orders

## Supabase setup

1. Create a Supabase project.
2. Open **SQL Editor** and run `supabase/schema.sql` from this repository.
3. In your deployment environment, add the variables shown in `.env.example`:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. Enable email/password authentication in Supabase Auth.
5. Run the app with `npm install && npm run dev`.

The browser only uses the public anon key. Never put a Supabase service-role key in client-side code or public environment variables.

## Next production milestones

1. Product image uploads with Supabase Storage
2. Buyer checkout and farmer order management
3. Buyer/farmer messaging
4. Reviews and seller trust signals
5. Server-side payment processing and 3% commission settlement
6. Delivery/driver matching
7. Admin moderation and analytics
8. Premium listings and business accounts

## Business model

Basic farmer access stays free initially. Revenue is planned from a small commission on successful transactions, promoted listings, premium business tools and future delivery revenue.

## Product principle

Start simple: help a farmer list produce and help a buyer find it. Add complexity only when real users need it.
