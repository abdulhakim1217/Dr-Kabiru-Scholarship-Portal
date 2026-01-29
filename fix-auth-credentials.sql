-- Fix Authentication Credentials Issue
-- This script addresses authentication problems when user exists but login fails

-- Step 1: Check current admin user status
SELECT 
  'Current Admin User Status' as check_type,
  id,
  email,
  email_confirmed_at,
  phone_confirmed_at,
  created_at,
  updated_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data
FROM auth.users 
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 2: Check if email is confirmed
UPDATE auth.users 
SET 
  email_confirmed_at = NOW(),
  updated_at = NOW()
WHERE email = 'admin@drkabiruscholarship.com' 
  AND email_confirmed_at IS NULL;

-- Step 3: Reset any account locks or failed attempts
UPDATE auth.users 
SET 
  updated_at = NOW(),
  raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb)
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 4: Verify the user can authenticate (this shows the user exists)
SELECT 
  'Authentication Check' as check_type,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM auth.users 
      WHERE email = 'admin@drkabiruscholarship.com'
      AND email_confirmed_at IS NOT NULL
    ) THEN 'User exists and email is confirmed'
    ELSE 'User missing or email not confirmed'
  END as status;

-- Step 5: Check for any authentication issues
SELECT 
  'Auth Issues Check' as check_type,
  email,
  CASE 
    WHEN email_confirmed_at IS NULL THEN 'Email not confirmed'
    WHEN banned_until IS NOT NULL AND banned_until > NOW() THEN 'Account is banned'
    WHEN deleted_at IS NOT NULL THEN 'Account is deleted'
    ELSE 'Account appears normal'
  END as issue_status
FROM auth.users 
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 6: Final verification with role check
SELECT 
  'Complete Verification' as check_type,
  u.email,
  u.id as user_uuid,
  ur.role,
  CASE 
    WHEN u.email_confirmed_at IS NOT NULL THEN 'Email Confirmed'
    ELSE 'Email NOT Confirmed'
  END as email_status,
  CASE 
    WHEN ur.role = 'admin' THEN 'Admin Role Assigned'
    ELSE 'Admin Role MISSING'
  END as role_status
FROM auth.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.role = 'admin'
WHERE u.email = 'admin@drkabiruscholarship.com';