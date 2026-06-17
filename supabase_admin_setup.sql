-- =====================================================
-- DRINK TRACKER — Admin Setup (fixed version)
-- Run this in Supabase → SQL Editor → Run
-- =====================================================

-- Step 1: Add is_admin column to profiles
alter table profiles add column if not exists is_admin boolean default false;

-- Step 2: Drop ALL existing policies on all tables (clean slate)
do $$
declare
  r record;
begin
  for r in
    select policyname, tablename
    from pg_policies
    where tablename in ('people','drink_logs','payments','replacements','profiles','audit_log')
  loop
    execute format('drop policy if exists %I on %I', r.policyname, r.tablename);
  end loop;
end$$;

-- Step 3: Recreate all policies with admin support

-- DRINK LOGS
create policy "select_auth"         on drink_logs for select using (auth.role() = 'authenticated');
create policy "insert_own"          on drink_logs for insert with check (auth.uid() = user_id);
create policy "delete_own_or_admin" on drink_logs for delete using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);
create policy "update_own_or_admin" on drink_logs for update using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);

-- PAYMENTS
create policy "select_auth"         on payments for select using (auth.role() = 'authenticated');
create policy "insert_own"          on payments for insert with check (auth.uid() = user_id);
create policy "delete_own_or_admin" on payments for delete using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);
create policy "update_own_or_admin" on payments for update using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);

-- REPLACEMENTS
create policy "select_auth"         on replacements for select using (auth.role() = 'authenticated');
create policy "insert_own"          on replacements for insert with check (auth.uid() = user_id);
create policy "delete_own_or_admin" on replacements for delete using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);
create policy "update_own_or_admin" on replacements for update using (
  auth.uid() = user_id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);

-- PROFILES
create policy "select_auth"         on profiles for select using (auth.role() = 'authenticated');
create policy "insert_own"          on profiles for insert with check (auth.uid() = id);
create policy "update_own_or_admin" on profiles for update using (
  auth.uid() = id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);
create policy "delete_own_or_admin" on profiles for delete using (
  auth.uid() = id
  or exists (select 1 from profiles where id = auth.uid() and is_admin = true)
);

-- AUDIT LOG
create policy "select_auth" on audit_log for select using (auth.role() = 'authenticated');
create policy "insert_own"  on audit_log for insert with check (auth.uid() = user_id);

-- Step 4: Set YOU as admin
-- *** Replace your@email.com with your actual email ***
update profiles
set is_admin = true
where id = (select id from auth.users where email = 'your@email.com');

-- Confirm it worked
select display_name, is_admin from profiles;
