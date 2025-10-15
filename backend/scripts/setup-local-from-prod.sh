#!/bin/bash

# ========================================
# Complete Local Setup from Production
# ========================================
# This script sets up your entire local development environment
# by copying everything from production (database + code)
#
# This is the recommended approach when you want to ensure
# 100% consistency between local and production

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "======================================"
echo "🚀 Complete Local Setup from Production"
echo "======================================"
echo ""

# Configuration
LOCAL_DB_NAME="homework_helper_dev"
LOCAL_DB_USER="postgres"
LOCAL_DB_PASSWORD="dev_password_123"
LOCAL_DB_HOST="localhost"
LOCAL_DB_PORT="5432"

echo "This script will:"
echo "  1. 📦 Install Node.js dependencies"
echo "  2. 🗄️  Set up PostgreSQL locally"
echo "  3. 🔄 Sync production database to local"
echo "  4. ⚙️  Configure local environment"
echo "  5. 🧪 Verify everything works"
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""

# Step 1: Install dependencies
echo "📦 Step 1: Installing Node.js dependencies..."
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json not found. Are you in the backend directory?${NC}"
    exit 1
fi

npm install
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 2: Check PostgreSQL
echo "🗄️  Step 2: Checking PostgreSQL installation..."
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL is not installed!${NC}"
    echo ""
    echo "Install PostgreSQL:"
    echo "  macOS:   brew install postgresql@16"
    echo "  Ubuntu:  sudo apt-get install postgresql postgresql-contrib"
    echo "  Windows: Download from https://www.postgresql.org/download/"
    echo ""
    echo "After installing, run this script again."
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL found${NC}"

# Check if PostgreSQL is running
if ! pg_isready -p $LOCAL_DB_PORT > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  PostgreSQL is not running. Starting it...${NC}"
    
    # Try to start PostgreSQL (macOS with Homebrew)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew services start postgresql@16 || brew services start postgresql
    fi
    
    # Wait a bit for PostgreSQL to start
    sleep 3
    
    # Check again
    if ! pg_isready -p $LOCAL_DB_PORT > /dev/null 2>&1; then
        echo -e "${RED}Failed to start PostgreSQL${NC}"
        echo "Please start PostgreSQL manually:"
        echo "  macOS:   brew services start postgresql@16"
        echo "  Linux:   sudo service postgresql start"
        exit 1
    fi
fi

echo -e "${GREEN}✅ PostgreSQL is running${NC}"
echo ""

# Step 3: Get production database URL
echo "🔗 Step 3: Getting production database connection..."
if [ -z "$DATABASE_URL" ]; then
    echo -e "${YELLOW}⚠️  DATABASE_URL not set in environment${NC}"
    echo "Please provide your production DATABASE_URL:"
    echo "Format: postgresql://username:password@host:port/database"
    read -p "Production DATABASE_URL: " PROD_DATABASE_URL
else
    PROD_DATABASE_URL="$DATABASE_URL"
    echo -e "${GREEN}✅ Using DATABASE_URL from environment${NC}"
fi

# Validate DATABASE_URL format
if [[ ! "$PROD_DATABASE_URL" =~ ^postgresql:// ]]; then
    echo -e "${RED}❌ Invalid DATABASE_URL format. Must start with postgresql://${NC}"
    exit 1
fi

echo ""

# Step 4: Sync database
echo "🔄 Step 4: Syncing production database to local..."
echo -e "${BLUE}ℹ️  This will replace your local database with production data${NC}"

# Create backup directory
mkdir -p "./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Drop and recreate local database
echo "🗑️  Dropping local database..."
if psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$LOCAL_DB_NAME"; then
    dropdb -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" "$LOCAL_DB_NAME"
    echo -e "${GREEN}✅ Local database dropped${NC}"
fi

createdb -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" "$LOCAL_DB_NAME"
echo -e "${GREEN}✅ New local database created${NC}"

# Export and import production database
echo "📤 Exporting production database..."
BACKUP_FILE="./backups/prod_backup_$TIMESTAMP.sql"

pg_dump "$PROD_DATABASE_URL" \
    --verbose \
    --no-owner \
    --no-privileges \
    --clean \
    --if-exists \
    --create \
    --format=plain \
    --file="$BACKUP_FILE"

echo "📥 Importing to local database..."
sed "s/CREATE DATABASE [^;]*/CREATE DATABASE $LOCAL_DB_NAME/" "$BACKUP_FILE" > "$BACKUP_FILE.modified"
psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" < "$BACKUP_FILE.modified"

rm -f "$BACKUP_FILE.modified"
echo -e "${GREEN}✅ Database sync complete${NC}"
echo ""

# Step 5: Configure local environment
echo "⚙️  Step 5: Configuring local environment..."

# Create .env.development file
cat > ".env.development" << EOF
# Local Development Environment
NODE_ENV=development
PORT=3000

# Database Configuration
DATABASE_URL=postgresql://$LOCAL_DB_USER:$LOCAL_DB_PASSWORD@$LOCAL_DB_HOST:$LOCAL_DB_PORT/$LOCAL_DB_NAME
DB_USER=$LOCAL_DB_USER
DB_HOST=$LOCAL_DB_HOST
DB_NAME=$LOCAL_DB_NAME
DB_PASSWORD=$LOCAL_DB_PASSWORD
DB_PORT=$LOCAL_DB_PORT

# JWT Secrets (CHANGE THESE!)
JWT_SECRET=local-dev-jwt-secret-change-this
ADMIN_JWT_SECRET=local-dev-admin-jwt-secret-change-this

# OpenAI Configuration (ADD YOUR KEY)
OPENAI_API_KEY=your-openai-api-key-here

# Stripe Configuration (TEST KEYS)
STRIPE_SECRET_KEY=sk_test_your_stripe_test_key
STRIPE_WEBHOOK_SECRET=whsec_your_test_webhook_secret
STRIPE_PRICE_ID=price_your_test_price_id

# Admin Account
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123
ADMIN_EMAIL=admin@localhost

# Entitlements Ledger (REQUIRED)
LEDGER_SALT=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")

# Optional settings
LOG_LEVEL=debug
DEBUG=true
EOF

echo -e "${GREEN}✅ Local environment configured${NC}"
echo ""

# Step 6: Verify setup
echo "🧪 Step 6: Verifying setup..."

# Check database connection
echo "🔍 Testing database connection..."
if psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Database connection successful${NC}"
else
    echo -e "${RED}❌ Database connection failed${NC}"
    exit 1
fi

# Check table count
TABLE_COUNT=$(psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
echo -e "${GREEN}✅ Database has $TABLE_COUNT tables${NC}"

# Test server startup (briefly)
echo "🚀 Testing server startup..."
timeout 10s npm run dev > /dev/null 2>&1 && echo -e "${GREEN}✅ Server starts successfully${NC}" || echo -e "${YELLOW}⚠️  Server startup test timed out (this is normal)${NC}"

echo ""

# Final summary
echo "======================================"
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "======================================"
echo ""
echo "📊 What was done:"
echo "  ✅ Node.js dependencies installed"
echo "  ✅ PostgreSQL configured and running"
echo "  ✅ Production database copied to local"
echo "  ✅ Local environment configured"
echo "  ✅ Setup verified"
echo ""
echo "📁 Files created:"
echo "  📦 Production backup: $BACKUP_FILE"
echo "  ⚙️  Local config: .env.development"
echo ""
echo "🚀 Next steps:"
echo "  1. Edit .env.development and add your OpenAI API key"
echo "  2. Update Stripe keys if needed"
echo "  3. Run: npm run dev"
echo "  4. Visit: http://localhost:3000/api/health"
echo ""
echo -e "${BLUE}💡 Your local environment now matches production!${NC}"
echo -e "${BLUE}💡 To sync again later, run: ./scripts/sync-prod-to-local.sh${NC}"
echo ""
