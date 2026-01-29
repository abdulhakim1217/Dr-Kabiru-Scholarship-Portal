-- Complete Admin Setup SQL
-- Run this entire script in Supabase SQL Editor

-- Step 1: Create user_roles table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'user', 'reviewer')),
  created_at timestamp with time zone DEFAULT now(),
  UNIQUE(user_id, role)
);

-- Step 2: Enable RLS on user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Step 3: Create RLS policies
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

-- Step 4: Create has_role function
CREATE OR REPLACE FUNCTION public.has_role(user_id uuid, role_name text)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_roles.user_id = $1 AND user_roles.role = $2
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Grant permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON public.user_roles TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_role TO authenticated;

-- Step 6: Check if admin user exists
DO $$
DECLARE
    admin_user_id uuid;
BEGIN
    -- Try to find existing admin user
    SELECT id INTO admin_user_id 
    FROM auth.users 
    WHERE email = 'admin@drkabiruscholarship.com';
    
    IF admin_user_id IS NOT NULL THEN
        -- User exists, add admin role if not already present
        INSERT INTO public.user_roles (user_id, role)
        VALUES (admin_user_id, 'admin')
        ON CONFLICT (user_id, role) DO NOTHING;
        
        RAISE NOTICE 'Admin role added for existing user: %', admin_user_id;
    ELSE
        RAISE NOTICE 'Admin user not found. Please create user via Authentication UI first.';
    END IF;
END $$;

-- Step 7: Verify setup
SELECT 
    'Admin user check' as check_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM auth.users u
            JOIN public.user_roles ur ON u.id = ur.user_id
            WHERE u.email = 'admin@drkabiruscholarship.com' 
            AND ur.role = 'admin'
        ) THEN 'SUCCESS: Admin user properly configured'
        ELSE 'FAILED: Admin user not found or role not assigned'
    END as status;