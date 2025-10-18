#!/bin/bash

# =============================================================================
# COMPLETE ADMIN PASSWORD FIX SCRIPT
# =============================================================================
# This script combines all admin password debugging and fixing functionality
# 
# USAGE:
#   ./admin-password-fix-complete.sh [debug|fix]
#
# OPTIONS:
#   debug - Only debug the current admin database state
#   fix   - Fix the admin password (default)
#
# REQUIREMENTS:
#   - Must be run in Azure App Service SSH console
#   - DATABASE_URL environment variable must be set
#   - Node.js and pg package must be available
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${CYAN}🔧 $1${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_header "CHECKING PREREQUISITES"
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ]; then
        print_error "Not in the correct directory. Please navigate to /home/site/wwwroot"
        echo "   Run: cd /home/site/wwwroot"
        exit 1
    fi
    
    print_success "In correct directory: $(pwd)"
    
    # Check if DATABASE_URL is set
    if [ -z "$DATABASE_URL" ]; then
        print_error "DATABASE_URL environment variable is not set!"
        echo "   This script must be run on the Azure App Service where DATABASE_URL is configured."
        exit 1
    fi
    
    print_success "DATABASE_URL is configured"
    print_info "Database: $(echo $DATABASE_URL | cut -d'@' -f2 | cut -d'/' -f1)"
    echo ""
}

# Function to create debug script
create_debug_script() {
    cat > debug-admin-database.js << 'EOF'
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function debugAdminDatabase() {
  try {
    console.log('🔍 DEBUGGING ADMIN DATABASE');
    console.log('============================');
    console.log('');
    
    // Check if admin_users table exists
    console.log('1️⃣ Checking if admin_users table exists...');
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'admin_users'
      );
    `);
    
    if (tableCheck.rows[0].exists) {
      console.log('✅ admin_users table exists');
    } else {
      console.log('❌ admin_users table does NOT exist!');
      console.log('   This is the problem - the table is missing.');
      return;
    }
    
    // Check table structure
    console.log('');
    console.log('2️⃣ Checking table structure...');
    const structure = await pool.query(`
      SELECT column_name, data_type, is_nullable 
      FROM information_schema.columns 
      WHERE table_name = 'admin_users'
      ORDER BY ordinal_position;
    `);
    
    console.log('📋 Table structure:');
    structure.rows.forEach(col => {
      console.log(`   ${col.column_name}: ${col.data_type} (${col.is_nullable === 'YES' ? 'nullable' : 'not null'})`);
    });
    
    // Check all admin users
    console.log('');
    console.log('3️⃣ Checking all admin users...');
    const allUsers = await pool.query('SELECT * FROM admin_users');
    
    if (allUsers.rows.length === 0) {
      console.log('❌ No admin users found in the database!');
      console.log('   This is why login fails - there are no admin users.');
    } else {
      console.log(`✅ Found ${allUsers.rows.length} admin user(s):`);
      allUsers.rows.forEach((user, index) => {
        console.log(`   User ${index + 1}:`);
        console.log(`     ID: ${user.id}`);
        console.log(`     Username: ${user.username}`);
        console.log(`     Email: ${user.email}`);
        console.log(`     Role: ${user.role}`);
        console.log(`     Active: ${user.is_active}`);
        console.log(`     Created: ${user.created_at}`);
        console.log(`     Password Hash Length: ${user.password_hash ? user.password_hash.length : 'NULL'}`);
        if (user.password_hash) {
          console.log(`     Hash starts with: ${user.password_hash.substring(0, 20)}...`);
          console.log(`     Hash Type: ${user.password_hash.startsWith('$2') ? 'bcrypt (WRONG)' : 'SHA256 (CORRECT)'}`);
        }
        console.log('');
      });
    }
    
    // Check specifically for 'admin' user
    console.log('4️⃣ Checking specifically for "admin" user...');
    const adminUser = await pool.query('SELECT * FROM admin_users WHERE username = $1', ['admin']);
    
    if (adminUser.rows.length === 0) {
      console.log('❌ No user with username "admin" found!');
    } else {
      const admin = adminUser.rows[0];
      console.log('✅ Found "admin" user:');
      console.log(`   ID: ${admin.id}`);
      console.log(`   Username: ${admin.username}`);
      console.log(`   Email: ${admin.email}`);
      console.log(`   Role: ${admin.role}`);
      console.log(`   Active: ${admin.is_active}`);
      console.log(`   Password Hash: ${admin.password_hash}`);
      console.log(`   Hash Length: ${admin.password_hash ? admin.password_hash.length : 'NULL'}`);
    }
    
    // Check other tables that might have admin data
    console.log('');
    console.log('5️⃣ Checking for other admin-related tables...');
    const otherTables = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_name LIKE '%admin%' OR table_name LIKE '%user%'
      AND table_schema = 'public'
      ORDER BY table_name;
    `);
    
    if (otherTables.rows.length > 0) {
      console.log('📋 Found other related tables:');
      otherTables.rows.forEach(table => {
        console.log(`   - ${table.table_name}`);
      });
    } else {
      console.log('❌ No other admin/user tables found');
    }
    
  } catch (error) {
    console.error('❌ Error debugging admin database:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

debugAdminDatabase();
EOF
}

# Function to create fix script
create_fix_script() {
    cat > fix-admin-password.js << 'EOF'
const crypto = require('crypto');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function fixAdminPassword() {
  try {
    console.log('🔧 FIXING ADMIN PASSWORD - COMPLETE SOLUTION');
    console.log('=============================================');
    console.log('Environment:', process.env.NODE_ENV);
    console.log('');
    
    const newEmail = 'support_homework@arshia.com';
    const newPassword = 'A@dMin%f$7';
    const username = 'admin';
    
    // Step 1: Check if admin_users table exists, create if not
    console.log('1️⃣ Ensuring admin_users table exists...');
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'admin_users'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      console.log('❌ admin_users table does not exist. Creating it...');
      
      await pool.query(`
        CREATE TABLE admin_users (
          id SERIAL PRIMARY KEY,
          username VARCHAR(100) UNIQUE NOT NULL,
          email VARCHAR(255) UNIQUE NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          role VARCHAR(50) DEFAULT 'admin',
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW(),
          last_login TIMESTAMP
        );
      `);
      
      console.log('✅ admin_users table created');
    } else {
      console.log('✅ admin_users table exists');
    }
    
    // Step 2: Check table structure and add missing columns
    console.log('');
    console.log('2️⃣ Checking table structure...');
    const structure = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'admin_users'
      ORDER BY ordinal_position;
    `);
    
    const columns = structure.rows.map(row => row.column_name);
    console.log('📋 Current columns:', columns.join(', '));
    
    // Add missing columns if needed (but don't fail if they already exist)
    const requiredColumns = {
      'username': 'VARCHAR(100) UNIQUE NOT NULL',
      'email': 'VARCHAR(255) UNIQUE NOT NULL', 
      'password_hash': 'VARCHAR(255) NOT NULL',
      'role': 'VARCHAR(50) DEFAULT \'admin\'',
      'is_active': 'BOOLEAN DEFAULT true',
      'created_at': 'TIMESTAMP DEFAULT NOW()'
    };
    
    for (const [colName, colDef] of Object.entries(requiredColumns)) {
      if (!columns.includes(colName)) {
        console.log(`   Adding missing column: ${colName}`);
        try {
          await pool.query(`ALTER TABLE admin_users ADD COLUMN ${colName} ${colDef};`);
        } catch (error) {
          console.log(`   Column ${colName} might already exist or error: ${error.message}`);
        }
      }
    }
    
    // Step 3: Delete any existing admin users to start fresh
    console.log('');
    console.log('3️⃣ Cleaning up existing admin users...');
    const deleteResult = await pool.query('DELETE FROM admin_users WHERE username = $1', [username]);
    console.log(`   Deleted ${deleteResult.rowCount} existing admin user(s)`);
    
    // Step 4: Create new admin user with correct hash
    console.log('');
    console.log('4️⃣ Creating new admin user...');
    const passwordHash = hashPassword(newPassword);
    
    const insertResult = await pool.query(`
      INSERT INTO admin_users (username, email, password_hash, role, is_active, created_at)
      VALUES ($1, $2, $3, 'super_admin', true, NOW())
      RETURNING id, username, email, role, is_active, created_at
    `, [username, newEmail, passwordHash]);
    
    if (insertResult.rows.length > 0) {
      const newAdmin = insertResult.rows[0];
      console.log('✅ New admin user created successfully!');
      console.log('');
      console.log('📋 Admin Details:');
      console.log(`   ID: ${newAdmin.id}`);
      console.log(`   Username: ${newAdmin.username}`);
      console.log(`   Email: ${newAdmin.email}`);
      console.log(`   Role: ${newAdmin.role}`);
      console.log(`   Active: ${newAdmin.is_active}`);
      console.log(`   Created: ${newAdmin.created_at}`);
    }
    
    // Step 5: Verify the admin user
    console.log('');
    console.log('5️⃣ Verifying admin user...');
    const verifyResult = await pool.query(
      'SELECT * FROM admin_users WHERE username = $1',
      [username]
    );
    
    if (verifyResult.rows.length > 0) {
      const admin = verifyResult.rows[0];
      console.log('✅ Admin user verified:');
      console.log(`   Username: ${admin.username}`);
      console.log(`   Email: ${admin.email}`);
      console.log(`   Role: ${admin.role}`);
      console.log(`   Active: ${admin.is_active}`);
      console.log(`   Password Hash Length: ${admin.password_hash.length}`);
      console.log(`   Hash starts with: ${admin.password_hash.substring(0, 20)}...`);
      
      // Test the hash
      const testHash = hashPassword(newPassword);
      if (admin.password_hash === testHash) {
        console.log('✅ Password hash verification successful!');
      } else {
        console.log('❌ Password hash verification failed!');
      }
    } else {
      console.log('❌ Admin user verification failed!');
    }
    
    // Step 6: Test login credentials
    console.log('');
    console.log('6️⃣ Testing login credentials...');
    
    const testResult = await pool.query(
      'SELECT * FROM admin_users WHERE username = $1 AND password_hash = $2',
      [username, passwordHash]
    );
    
    if (testResult.rows.length > 0) {
      console.log('✅ Login credentials test successful!');
      console.log('');
      console.log('🎉 COMPLETE ADMIN FIX SUCCESSFUL!');
      console.log('==================================');
      console.log('');
      console.log('🔑 Your new admin credentials:');
      console.log('   Username: admin');
      console.log('   Password: A@dMin%f$7');
      console.log('   Email: support_homework@arshia.com');
      console.log('');
      console.log('🌐 Admin Portal URL:');
      if (process.env.NODE_ENV === 'production') {
        console.log('   https://homework-helper-api.azurewebsites.net/admin/');
      } else {
        console.log('   https://homework-helper-staging.azurewebsites.net/admin/');
      }
      console.log('');
      console.log('⚠️  IMPORTANT: Change the password immediately after logging in!');
      console.log('');
      console.log('🔒 Security Recommendations:');
      console.log('   1. Login with the credentials above');
      console.log('   2. Change to a strong, unique password');
      console.log('   3. Enable 2FA if available');
      console.log('   4. Update the password in your password manager');
    } else {
      console.log('❌ Login credentials test failed!');
    }
    
  } catch (error) {
    console.error('❌ Error in complete admin fix:', error.message);
    console.error('Full error:', error);
    
    if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
      console.error('');
      console.error('🔧 Database Connection Issue:');
      console.error('   - Check if the database server is running');
      console.error('   - Verify the DATABASE_URL is correct');
      console.error('   - Check network connectivity');
    }
    
    process.exit(1);
  } finally {
    await pool.end();
  }
}

fixAdminPassword();
EOF
}

# Function to run debug
run_debug() {
    print_header "RUNNING ADMIN DATABASE DEBUG"
    
    create_debug_script
    print_success "Debug script created"
    echo ""
    
    print_step "Running database debug..."
    echo ""
    node debug-admin-database.js
    
    # Clean up
    echo ""
    print_info "Cleaning up..."
    rm -f debug-admin-database.js
    print_success "Cleanup complete"
}

# Function to run fix
run_fix() {
    print_header "RUNNING COMPLETE ADMIN PASSWORD FIX"
    
    create_fix_script
    print_success "Fix script created"
    echo ""
    
    print_step "Running complete admin fix..."
    echo ""
    node fix-admin-password.js
    
    # Clean up
    echo ""
    print_info "Cleaning up..."
    rm -f fix-admin-password.js
    print_success "Cleanup complete"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [debug|fix]"
    echo ""
    echo "Options:"
    echo "  debug  - Only debug the current admin database state"
    echo "  fix    - Fix the admin password (default)"
    echo ""
    echo "Examples:"
    echo "  $0        # Run the fix (default)"
    echo "  $0 fix    # Run the fix"
    echo "  $0 debug  # Only debug, don't fix"
}

# Main script logic
main() {
    # Parse command line arguments
    MODE=${1:-fix}
    
    case $MODE in
        debug)
            print_header "ADMIN PASSWORD DEBUG MODE"
            echo "This will only debug the database state without making changes."
            echo ""
            check_prerequisites
            run_debug
            ;;
        fix)
            print_header "ADMIN PASSWORD FIX MODE"
            echo "This will fix the admin password by converting bcrypt to SHA256."
            echo ""
            check_prerequisites
            run_fix
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $MODE"
            show_usage
            exit 1
            ;;
    esac
    
    echo ""
    print_success "SCRIPT COMPLETED SUCCESSFULLY!"
    echo ""
    print_info "What this script does:"
    echo "✅ Creates admin_users table if missing"
    echo "✅ Adds missing columns if needed"
    echo "✅ Deletes old admin users"
    echo "✅ Creates fresh admin user with correct SHA256 hash"
    echo "✅ Verifies the fix worked"
    echo "✅ Tests login credentials"
    echo ""
    print_warning "If you still get 'Invalid credentials', the issue might be:"
    echo "1. Wrong admin portal URL"
    echo "2. Cached login session - try incognito mode"
    echo "3. Different authentication system"
    echo "4. Network/firewall issues"
}

# Run main function
main "$@"
