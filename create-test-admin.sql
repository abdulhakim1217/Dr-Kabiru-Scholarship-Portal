-- Create a Test Admin User with Different Email
-- This will help us determine if the issue is with the specific email or the system

-- Step 1: Create a test admin role for any user that logs in successfully
-- We'll use a simple email that's easier to type and test

SELECT 'CREATING TEST ADMIN USER' as step;

-- Step 2: Instructions for creating test user
SELECT 'Go to Authentication > Users and create:' as instruction;
SELECT 'Email: test@admin.com' as test_email;
SELECT 'Password: admin123' as test_password;
SELECT 'Make sure to check Auto Confirm User' as important;

-- Step 3: After creating the test user, this will assign admin role
DO $
DECLARE
    test_user_id uuid;
BEGIN
    -- Get the test user ID
    SELECT id INTO test_user_id 
    FROM auth.users 
    WHERE email = 'test@admin.com';
    
    IF test_user_id IS NOT NULL THEN
        -- Insert admin role for test user
        INSERT INTO public.user_roles (user_id, role)
        VALUES (test_user_id, 'admin')
        ON CONFLICT (user_id, role) DO NOTHING;
        
        RAISE NOTICE 'SUCCESS: Test admin role added for user %', test_user_id;
    ELSE
        RAISE NOTICE 'Test user not found. Create test@admin.com first.';
    END IF;
END $;

-- Step 4: Verify test admin setup
SELECT 
  'TEST ADMIN VERIFICATION' as check_type,
  u.email,
  u.id as user_uuid,
  ur.role,
  CASE 
    WHEN u.email_confirmed_at IS NOT NULL THEN 'Email CONFIRMED ✅'
    ELSE 'Email NOT CONFIRMED ❌'
  END as email_status,
  CASE 
    WHEN ur.role = 'admin' THEN 'Admin Role ASSIGNED ✅'
    ELSE 'Admin Role MISSING ❌'
  END as role_status
FROM auth.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id AND ur.role = 'admin'
WHERE u.email = 'test@admin.com';

-- Step 5: Show both admin users for comparison
SELECT 
  'ALL ADMIN USERS' as info,
  u.email,
  u.id,
  ur.role,
  u.email_confirmed_at,
  u.created_at
FROM auth.users u
JOIN public.user_roles ur ON u.id = ur.user_id
WHERE ur.role = 'admin'
ORDER BY u.created_at DESC;