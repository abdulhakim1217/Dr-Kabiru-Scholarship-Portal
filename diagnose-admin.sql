-- Comprehensive Admin Diagnosis and Fix
-- Run this entire script in Supabase SQL Editor

-- Step 1: Check if user_roles table exists
SELECT 
  'Table Check' as check_type,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'user_roles'
    ) THEN 'user_roles table EXISTS'
    ELSE 'user_roles table MISSING'
  END as status;

-- Step 2: Check if admin user exists in auth.users
SELECT 
  'Auth User Check' as check_type,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM auth.users 
      WHERE email = 'admin@drkabiruscholarship.com'
    ) THEN 'Admin user EXISTS in auth.users'
    ELSE 'Admin user MISSING from auth.users'
  END as status;

-- Step 3: Show actual admin user details if exists
SELECT 
  'Admin User Details' as info_type,
  id as user_uuid,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email = 'admin@drkabiruscholarship.com';

-- Step 4: Check user_roles entries
SELECT 
  'User Roles Check' as info_type,
  user_id,
  role,
  created_at
FROM public.user_roles 
WHERE role = 'admin';

-- Step 5: Check if the UUID in user_roles matches any real user
SELECT 
  'UUID Match Check' as check_type,
  ur.user_id as role_uuid,
  u.id as auth_uuid,
  u.email,
  CASE 
    WHEN u.id IS NOT NULL THEN 'UUID MATCHES real user'
    ELSE 'UUID does NOT match any user'
  END as status
FROM public.user_roles ur
LEFT JOIN auth.users u ON ur.user_id = u.id
WHERE ur.role = 'admin';

-- Step 6: Create user_roles table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'user', 'reviewer')),
  created_at timestamp with time zone DEFAULT now(),
  UNIQUE(user_id, role)
);

-- Step 7: Enable RLS and create policies
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own roles" ON public.user_roles;
CREATE POLICY "Users can view own roles" ON public.user_roles
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;
CREATE POLICY "Admins can view all roles" ON public.user_roles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.user_roles ur 
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- Step 8: Fix admin role assignment
DO $
DECLARE
    admin_user_id uuid;
BEGIN
    -- Get the actual admin user UUID
    SELECT id INTO admin_user_id 
    FROM auth.users 
    WHERE email = 'admin@drkabiruscholarship.com';
    
    IF admin_user_id IS NOT NULL THEN
        -- Delete any incorrect admin role entries
        DELETE FROM public.user_roles WHERE role = 'admin';
        
        -- Insert correct admin role
        INSERT INTO public.user_roles (user_id, role)
        VALUES (admin_user_id, 'admin');
        
        RAISE NOTICE 'Admin role fixed for user: %', admin_user_id;
    ELSE
        RAISE NOTICE 'ERROR: Admin user not found in auth.users. Please create user first.';
    END IF;
END $;

-- Step 9: Final verification
SELECT 
  'Final Verification' as check_type,
  u.email,
  u.id as user_uuid,
  ur.role,
  ur.created_at,
  CASE 
    WHEN u.email_confirmed_at IS NOT NULL THEN 'Email CONFIRMED'
    ELSE 'Email NOT CONFIRMED'
  END as email_status
FROM auth.users u
JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email = 'admin@drkabiruscholarship.com' AND ur.role = 'admin';