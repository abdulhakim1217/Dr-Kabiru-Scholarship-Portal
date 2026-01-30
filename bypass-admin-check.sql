-- Temporary Bypass: Make ANY logged-in user an admin
-- This will help us test if the issue is with authentication or role checking

-- WARNING: This makes ANY user who logs in an admin
-- Only use for testing, then remove this afterwards

-- Step 1: Create a function that always returns true for admin check
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS boolean AS $
BEGIN
  -- Temporarily return true for any authenticated user
  RETURN auth.uid() IS NOT NULL;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Create a policy that allows any authenticated user to be admin
DROP POLICY IF EXISTS "Temporary admin access for testing" ON public.user_roles;
CREATE POLICY "Temporary admin access for testing" ON public.user_roles
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Step 3: Instructions
SELECT 'TEMPORARY BYPASS ACTIVATED' as status;
SELECT 'Now try logging in with ANY valid user account' as instruction;
SELECT 'You can create a simple user: user@test.com / password123' as suggestion;
SELECT 'If this works, the issue is with the specific admin user setup' as diagnosis;
SELECT 'If this fails, the issue is with the authentication system itself' as diagnosis2;

-- Step 4: To remove this bypass later, run:
SELECT 'TO REMOVE BYPASS LATER:' as cleanup;
SELECT 'DROP FUNCTION public.is_admin_user();' as cleanup_step1;
SELECT 'DROP POLICY "Temporary admin access for testing" ON public.user_roles;' as cleanup_step2;