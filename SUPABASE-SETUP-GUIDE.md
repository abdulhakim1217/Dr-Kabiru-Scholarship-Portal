# 🚀 Supabase Setup Guide

## Step 1: Create Supabase Project

### A. Go to Supabase
1. Visit: https://supabase.com
2. Click "Start your project" 
3. Sign up with GitHub (recommended) or email

### B. Create New Project
1. Click "New Project" (green button)
2. Fill in:
   - **Name**: `Dr Kabiru Scholarship Portal`
   - **Database Password**: Create a strong password (SAVE THIS!)
   - **Region**: Choose closest to your location
3. Click "Create new project"
4. ⏳ Wait 2-3 minutes for setup

### C. Get Your Project Details
1. Once created, note your **Project URL**: `https://[project-id].supabase.co`
2. Go to **Settings** → **API**
3. Copy these keys:
   - **Project URL**
   - **anon/public key** 
   - **service_role key** (keep this secret!)

## Step 2: Update Project Configuration

### A. Update the configuration script
1. Open `update-supabase-config.js`
2. Replace these values with your actual Supabase details:
   ```javascript
   const NEW_SUPABASE_CONFIG = {
     PROJECT_ID: 'your-actual-project-id',  // From the URL
     URL: 'https://your-actual-project-id.supabase.co',
     ANON_KEY: 'your-actual-anon-key',
     SERVICE_KEY: 'your-actual-service-key'
   };
   ```

### B. Run the update script
```bash
node update-supabase-config.js
```

## Step 3: Set Up Database

### A. Run Database Migrations
1. In Supabase dashboard, go to **SQL Editor**
2. Copy and paste the content from `supabase/migrations/20250125000001_create_admin_user.sql`
3. Click "Run" to execute the SQL

### B. Create Admin User
```bash
npm run setup-admin
```

## Step 4: Deploy to Vercel

1. Go to vercel.com
2. Import your GitHub repository
3. Add environment variables (from your updated .env file):
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`

## 🎯 What You'll Get

After completing these steps:
- ✅ Working Supabase database
- ✅ Admin user created
- ✅ Live scholarship portal
- ✅ Admin dashboard access

## 🔧 Troubleshooting

### If you can't find your project:
- Make sure you're logged into the correct Supabase account
- Check if the project is in a different organization
- Try refreshing the dashboard

### If migrations fail:
- Make sure you copied the entire SQL content
- Check for any syntax errors in the SQL editor
- Try running smaller parts of the migration separately

## 📞 Need Help?

If you get stuck:
1. Check the Supabase project logs
2. Verify your API keys are correct
3. Make sure the database password is saved