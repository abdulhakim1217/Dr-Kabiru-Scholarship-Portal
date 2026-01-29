# 🔧 Admin Login Fix Guide

## 🚨 Current Issue
You've inserted UUID `22d19fab-8579-4f84-a9e2-0351bc6000e1` for admin access but still getting "wrong credentials" error.

## 🎯 **IMMEDIATE SOLUTION - Follow These Steps:**

### **Step 1: Run Diagnostic Script**
1. Go to your Supabase project dashboard
2. Click **"SQL Editor"** in the left sidebar
3. Copy and paste the entire content from `diagnose-admin.sql`
4. Click **"Run"** button
5. **Review the output** - it will tell you exactly what's wrong

### **Step 2: Create Admin User (If Missing)**
If the diagnostic shows "Admin user MISSING from auth.users":

1. Go to **Authentication** → **Users**
2. Click **"Add User"**
3. Fill in:
   ```
   Email: admin@drkabiruscholarship.com
   Password: DrKabiru2025!Admin
   ✅ Confirm email: CHECK THIS BOX
   ```
4. Click **"Add User"**

### **Step 3: Fix Admin Role Assignment**
The diagnostic script will automatically:
- Delete any incorrect admin role entries
- Insert the correct admin role with the real user UUID
- Verify the setup

### **Step 4: Test Login**
1. Go to: `https://your-vercel-url.vercel.app/admin`
2. Enter credentials:
   - Email: `admin@drkabiruscholarship.com`
   - Password: `DrKabiru2025!Admin`
3. Should work now!

## 🔍 **What the Diagnostic Will Show:**

### **Possible Issues:**
1. **"user_roles table MISSING"** → Script will create it
2. **"Admin user MISSING from auth.users"** → You need to create user via Step 2
3. **"UUID does NOT match any user"** → Script will fix with correct UUID
4. **"Email NOT CONFIRMED"** → User exists but email not confirmed

### **Success Indicators:**
- ✅ "user_roles table EXISTS"
- ✅ "Admin user EXISTS in auth.users"  
- ✅ "UUID MATCHES real user"
- ✅ "Email CONFIRMED"

## 🚀 **Quick Fix Commands**

If you want to do it manually after creating the user:

```sql
-- Get the real admin user UUID
SELECT id, email FROM auth.users WHERE email = 'admin@drkabiruscholarship.com';

-- Delete old admin roles
DELETE FROM public.user_roles WHERE role = 'admin';

-- Insert correct admin role (replace REAL_UUID_HERE)
INSERT INTO public.user_roles (user_id, role)
VALUES ('REAL_UUID_HERE', 'admin');
```

## 🎯 **Why This Happened:**
The UUID `22d19fab-8579-4f84-a9e2-0351bc6000e1` you inserted doesn't match any actual user in the `auth.users` table. This happens when:
- User was never created in Authentication
- User was created but with different UUID
- User was deleted and recreated

## ✅ **After Fix - You Should See:**
- Login works with `admin@drkabiruscholarship.com` / `DrKabiru2025!Admin`
- Redirected to `/admin/dashboard`
- Admin interface loads with statistics
- Can view/manage applications

**Run the diagnostic script first - it will tell you exactly what needs to be fixed! 🔧**