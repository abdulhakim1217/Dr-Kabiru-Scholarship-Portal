// Update Supabase Configuration Script
// Run this after creating your Supabase project
// Usage: node update-supabase-config.js

import fs from 'fs';
import path from 'path';

// REPLACE THESE WITH YOUR ACTUAL SUPABASE PROJECT DETAILS
const NEW_SUPABASE_CONFIG = {
  PROJECT_ID: 'your-project-id-here',  // Get from Supabase dashboard URL
  URL: 'https://your-project-id-here.supabase.co',  // Your project URL
  ANON_KEY: 'your-anon-key-here',  // Get from Settings → API → anon/public key
  SERVICE_KEY: 'your-service-key-here'  // Get from Settings → API → service_role key (keep secret!)
};

console.log('🔧 Updating Supabase configuration...');

// Update .env file
const envContent = `# Supabase Configuration
VITE_SUPABASE_PROJECT_ID="${NEW_SUPABASE_CONFIG.PROJECT_ID}"
VITE_SUPABASE_URL="${NEW_SUPABASE_CONFIG.URL}"
VITE_SUPABASE_PUBLISHABLE_KEY="${NEW_SUPABASE_CONFIG.ANON_KEY}"
`;

fs.writeFileSync('.env', envContent);
console.log('✅ Updated .env file');

// Update .env.example
fs.writeFileSync('.env.example', envContent);
console.log('✅ Updated .env.example file');

// Update setup-admin.js
const setupAdminContent = `// Admin Setup Script
// Run this script to create the admin user
// Usage: node setup-admin.js

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = '${NEW_SUPABASE_CONFIG.URL}';
const SUPABASE_SERVICE_KEY = '${NEW_SUPABASE_CONFIG.SERVICE_KEY}';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function createAdminUser() {
  const adminEmail = 'admin@drkabiruscholarship.com';
  const adminPassword = 'DrKabiru2025!Admin';
  
  try {
    console.log('Creating admin user...');
    
    // Create the user
    const { data: user, error: userError } = await supabase.auth.admin.createUser({
      email: adminEmail,
      password: adminPassword,
      email_confirm: true
    });
    
    if (userError) {
      console.error('Error creating user:', userError);
      return;
    }
    
    console.log('User created successfully:', user.user.id);
    
    // Add admin role
    const { error: roleError } = await supabase
      .from('user_roles')
      .insert({
        user_id: user.user.id,
        role: 'admin'
      });
    
    if (roleError) {
      console.error('Error adding admin role:', roleError);
      return;
    }
    
    console.log('✅ Admin user created successfully!');
    console.log('📧 Email:', adminEmail);
    console.log('🔑 Password:', adminPassword);
    console.log('🌐 Login URL: https://yoursite.com/admin');
    
  } catch (error) {
    console.error('Setup failed:', error);
  }
}

createAdminUser();`;

fs.writeFileSync('setup-admin.js', setupAdminContent);
console.log('✅ Updated setup-admin.js file');

console.log('\n🎉 Configuration updated successfully!');
console.log('\nNext steps:');
console.log('1. Run the database migrations in Supabase');
console.log('2. Run: npm run setup-admin');
console.log('3. Deploy to Vercel');