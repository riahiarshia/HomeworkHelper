#!/bin/bash

# Run Admin Fix Script on Staging
# This script will execute the admin fix directly on the staging environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
APP_NAME="homework-helper-staging"
RESOURCE_GROUP="homework-helper-rg"

print_status "🔧 Running Admin Fix on Staging Environment"
print_status "App Name: $APP_NAME"

# Check if Azure CLI is logged in
if ! az account show &> /dev/null; then
    print_error "Not logged into Azure CLI. Please run 'az login' first."
    exit 1
fi

print_status "✅ Azure CLI authenticated"

# Create a temporary script file with the admin fix code
print_status "📝 Creating admin fix script..."

cat > temp-admin-fix.js << 'EOF'
// Fix Staging Admin Credentials
const crypto = require('crypto');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function fixStagingAdmin() {
  try {
    console.log('🔐 Fixing staging admin credentials...');
    
    const username = 'admin';
    const email = 'admin@homeworkhelper-staging.com';
    const password = 'Admin123!Staging';
    const passwordHash = hashPassword(password);
    
    console.log('📋 Setting up admin with:');
    console.log('   Username:', username);
    console.log('   Email:', email);
    console.log('   Password:', password);
    
    // First, try to update existing admin
    const updateResult = await pool.query(
      `UPDATE admin_users 
       SET email = $1, password_hash = $2, is_active = true
       WHERE username = $3 
       RETURNING id, username, email, role`,
      [email, passwordHash, username]
    );
    
    if (updateResult.rows.length > 0) {
      console.log('✅ Updated existing admin user');
    } else {
      console.log('⏳ No existing admin found, creating new one...');
      
      const createResult = await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active)
         VALUES ($1, $2, $3, 'super_admin', true)
         RETURNING id, username, email, role`,
        [username, email, passwordHash]
      );
      
      if (createResult.rows.length > 0) {
        console.log('✅ Created new admin user');
      } else {
        throw new Error('Failed to create admin user');
      }
    }
    
    console.log('\n🎉 SUCCESS! Admin credentials are now set up.');
    console.log('\n🔑 Login Credentials:');
    console.log('   URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('   Username: admin');
    console.log('   Password: Admin123!Staging');
    console.log('\n✅ You can now login to the admin portal!');
    
  } catch (error) {
    console.error('❌ Error fixing admin credentials:', error.message);
    console.error('Full error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

fixStagingAdmin();
EOF

print_status "📤 Uploading and running script on Azure..."

# Upload the script and run it
az webapp ssh \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --command "cd /home/site/wwwroot && cat > fix-staging-admin.js << 'SCRIPT_EOF'
$(cat temp-admin-fix.js)
SCRIPT_EOF
node fix-staging-admin.js"

# Clean up temporary file
rm -f temp-admin-fix.js

if [ $? -eq 0 ]; then
    print_success "✅ Admin credentials updated successfully!"
    print_success ""
    print_success "🔑 New Admin Credentials:"
    print_success "   URL: https://$APP_NAME.azurewebsites.net/admin/"
    print_success "   Username: admin"
    print_success "   Password: Admin123!Staging"
    print_success ""
    print_success "✅ You can now login to the admin portal!"
else
    print_error "❌ Failed to update admin credentials"
    print_error "You may need to run this manually via Kudu console"
fi

print_status "🎉 Admin fix complete!"
