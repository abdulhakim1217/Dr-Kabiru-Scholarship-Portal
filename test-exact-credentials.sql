-- Test Exact Credentials and Debug Authentication
-- Run this to verify everything is set up correctly

-- Step 1: Verify admin user exists and is confirmed
SELECT 
  'ADMIN USER VERIFICATION' as step,
  id as user_uuid,
  email,
  email_confirmed_at,
  phone_confirmed_at,
  created_at,
  updated_at,
  last_sign_in_at,
  CASE 
    WHEN email_confirmed_at IS NOT NULL THEN '✅ EMAIL CONFIRMED'
    ELSE '❌ EMAIL NOT CONFIRMED'
  END as email_status,
  CASE 
    WHEN banned_until IS NULL OR banned_until < NOW() THEN '✅ ACCOUNT NOT BANNED'
    ELSE '❌ ACCOUNT IS BANNED'
  END as ban_status,
  CASE 
    WHEN deleted_at IS NULL THEN '✅ ACCOUNT NOT DELETED'
    ELSE '❌ ACCOUNT IS DELETED'
  END as deletion_status
FROM auth.users 
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 2: Verify admin role is assigned
SELECT 
  'ADMIN ROLE VERIFICATION' as step,
  ur.user_id,
  ur.role,
  ur.created_at,
  u.email,
  CASE 
    WHEN ur.role = 'admin' THEN '✅ ADMIN ROLE ASSIGNED'
    ELSE '❌ ADMIN ROLE MISSING'
  END as role_status
FROM public.user_roles ur
JOIN auth.users u ON ur.user_id = u.id
WHERE ur.role = 'admin' AND u.email = 'admin@drkabiruscholarship.com';

-- Step 3: Check for any authentication blocks or issues
SELECT 
  'AUTHENTICATION ISSUES CHECK' as step,
  email,
  CASE 
    WHEN email_confirmed_at IS NULL THEN 'Email not confirmed - this will cause login failure'
    WHEN banned_until IS NOT NULL AND banned_until > NOW() THEN 'Account is banned'
    WHEN deleted_at IS NOT NULL THEN 'Account is soft deleted'
    WHEN raw_app_meta_data ? 'provider' AND raw_app_meta_data->>'provider' != 'email' THEN 'Account created with different provider'
    ELSE 'No obvious authentication issues found'
  END as potential_issue
FROM auth.users 
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 4: Show the exact user data for debugging
SELECT 
  'COMPLETE USER DATA' as step,
  id,
  aud,
  role,
  email,
  encrypted_password IS NOT NULL as has_password,
  email_confirmed_at,
  invited_at,
  confirmation_token,
  confirmation_sent_at,
  recovery_token,
  recovery_sent_at,
  email_change_token_new,
  email_change,
  email_change_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  created_at,
  updated_at,
  phone,
  phone_confirmed_at,
  phone_change,
  phone_change_token,
  phone_change_sent_at,
  email_change_token_current,
  email_change_confirm_status,
  banned_until,
  reauthentication_token,
  reauthentication_sent_at,
  is_sso_user,
  deleted_at
FROM auth.users 
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 5: Final summary
SELECT 
  'FINAL DIAGNOSIS' as step,
  CASE 
    WHEN NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@drkabiruscholarship.com')
    THEN '❌ USER DOES NOT EXIST'
    WHEN EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@drkabiruscholarship.com' AND email_confirmed_at IS NULL)
    THEN '❌ USER EXISTS BUT EMAIL NOT CONFIRMED'
    WHEN EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@drkabiruscholarship.com' AND (banned_until IS NOT NULL AND banned_until > NOW()))
    THEN '❌ USER EXISTS BUT IS BANNED'
    WHEN EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@drkabiruscholarship.com' AND deleted_at IS NOT NULL)
    THEN '❌ USER EXISTS BUT IS DELETED'
    WHEN NOT EXISTS (
      SELECT 1 FROM auth.users u 
      JOIN public.user_roles ur ON u.id = ur.user_id 
      WHERE u.email = 'admin@drkabiruscholarship.com' AND ur.role = 'admin'
    )
    THEN '❌ USER EXISTS BUT NO ADMIN ROLE'
    ELSE '✅ USER AND ROLE SETUP APPEARS CORRECT - CHECK PASSWORD'
  END as diagnosis;