-- Password Reset Fix for Admin User
-- If user exists but password doesn't work, this will reset it

-- Step 1: Verify current admin user
SELECT 
  'Current Admin User' as info,
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 2: Force email confirmation if not confirmed
UPDATE auth.users 
SET 
  email_confirmed_at = NOW(),
  updated_at = NOW()
WHERE email = 'admin@drkabiruscholarship.com' 
  AND email_confirmed_at IS NULL;

-- Step 3: Clear any potential locks or bans
UPDATE auth.users 
SET 
  banned_until = NULL,
  updated_at = NOW()
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 4: Reset any failed login attempts (if tracked)
UPDATE auth.users 
SET 
  raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb),
  updated_at = NOW()
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 5: Verification after fixes
SELECT 
  'After Fixes' as info,
  email,
  CASE 
    WHEN email_confirmed_at IS NOT NULL THEN '✅ Email Confirmed'
    ELSE '❌ Email Not Confirmed'
  END as email_status,
  CASE 
    WHEN banned_until IS NULL THEN '✅ Not Banned'
    ELSE '❌ Still Banned'
  END as ban_status,
  updated_at
FROM auth.users 
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 6: Instructions for manual password reset
SELECT 'MANUAL PASSWORD RESET REQUIRED' as action_needed;
SELECT 'Go to Supabase Authentication > Users' as step_1;
SELECT 'Find admin@drkabiruscholarship.com' as step_2;
SELECT 'Click three dots (...) > Reset Password' as step_3;
SELECT 'Set password to: DrKabiru2025!Admin' as step_4;
SELECT 'Make sure Auto Confirm is checked' as step_5;