-- =====================================================
-- Run this in Supabase → SQL Editor → Run
-- Adds admin role to the drink tracker
-- =====================================================

-- 1. Add is_admin column to profiles
alter table profiles add column if not exists is_admin boolean default false;

-- 2. Set YOUR account as admin
-- Replace 'your@email.com' with the email you used to sign up
update profiles
set is_admin = true
where id = (
  select id from auth.users where email = 'your@email.com'
);

-- 3. Update RLS policies to allow admin to do everything

-- DRINK LOGS
drop policy if exists "delete_own" on drink_logs;
create policy "delete_own_or_admin" on drink_logs for delete using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);
create policy "update_own_or_admin" on drink_logs for update using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);

-- PAYMENTS
drop policy if exists "delete_own" on payments;
create policy "delete_own_or_admin" on payments for delete using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);
create policy "update_own_or_admin" on payments for update using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);

-- REPLACEMENTS
drop policy if exists "delete_own" on replacements;
create policy "delete_own_or_admin" on replacements for delete using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);
create policy "update_own_or_admin" on replacements for update using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);

-- PEOPLE / PROFILES
drop policy if exists "delete_own" on profiles;
create policy "delete_own_or_admin" on profiles for delete using (
  auth.uid() = id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);
create policy "update_own_or_admin" on profiles for update using (
  auth.uid() = id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);

-- =====================================================
-- Done! Go back to the app — you'll see admin controls.
-- =====================================================
