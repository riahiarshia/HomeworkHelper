#!/bin/bash

# ========================================
# Production to Local Database Sync
# ========================================
# This script syncs your Azure production database to local development
# 
# Prerequisites:
# 1. Azure CLI installed and logged in
# 2. PostgreSQL installed locally
# 3. Production DATABASE_URL in environment or .env file
# 4. Local database credentials configured

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "======================================"
echo "🔄 Production to Local Database Sync"
echo "======================================"
echo ""

# Configuration
LOCAL_DB_NAME="homework_helper_dev"
LOCAL_DB_USER="postgres"
LOCAL_DB_PASSWORD="dev_password_123"
LOCAL_DB_HOST="localhost"
LOCAL_DB_PORT="5432"

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/prod_backup_$TIMESTAMP.sql"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command_exists psql; then
    echo -e "${RED}❌ PostgreSQL client (psql) not found${NC}"
    echo "Install PostgreSQL:"
    echo "  macOS: brew install postgresql@16"
    echo "  Ubuntu: sudo apt-get install postgresql-client"
    exit 1
fi

if ! command_exists az; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    echo "Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged into Azure
if ! az account show >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not logged into Azure CLI${NC}"
    echo "Please run: az login"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Get production DATABASE_URL
echo "🔗 Getting production database connection..."
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

# Test production connection
echo "🔍 Testing production database connection..."
if ! psql "$PROD_DATABASE_URL" -c "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${RED}❌ Cannot connect to production database${NC}"
    echo "Please check your DATABASE_URL and network connection"
    exit 1
fi

echo -e "${GREEN}✅ Production database connection successful${NC}"
echo ""

# Backup current local database (if exists)
echo "💾 Backing up current local database..."
if psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$LOCAL_DB_NAME"; then
    echo -e "${YELLOW}📦 Local database exists, creating backup...${NC}"
    LOCAL_BACKUP_FILE="$BACKUP_DIR/local_backup_$TIMESTAMP.sql"
    pg_dump -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" "$LOCAL_DB_NAME" > "$LOCAL_BACKUP_FILE"
    echo -e "${GREEN}✅ Local backup saved to: $LOCAL_BACKUP_FILE${NC}"
else
    echo -e "${BLUE}ℹ️  Local database doesn't exist, no backup needed${NC}"
fi
echo ""

# Drop and recreate local database
echo "🗑️  Dropping local database..."
if psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$LOCAL_DB_NAME"; then
    dropdb -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" "$LOCAL_DB_NAME"
    echo -e "${GREEN}✅ Local database dropped${NC}"
fi

createdb -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" "$LOCAL_DB_NAME"
echo -e "${GREEN}✅ New local database created${NC}"
echo ""

# Export production database
echo "📤 Exporting production database..."
echo -e "${BLUE}ℹ️  This may take several minutes depending on database size...${NC}"

# Export schema and data
pg_dump "$PROD_DATABASE_URL" \
    --verbose \
    --no-owner \
    --no-privileges \
    --clean \
    --if-exists \
    --create \
    --format=plain \
    --file="$BACKUP_FILE"

echo -e "${GREEN}✅ Production database exported to: $BACKUP_FILE${NC}"
echo ""

# Import to local database
echo "📥 Importing to local database..."
echo -e "${BLUE}ℹ️  This may take several minutes...${NC}"

# Modify the backup file to use local database name
sed "s/CREATE DATABASE [^;]*/CREATE DATABASE $LOCAL_DB_NAME/" "$BACKUP_FILE" > "$BACKUP_FILE.modified"

# Import the modified backup
psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" < "$BACKUP_FILE.modified"

echo -e "${GREEN}✅ Production database imported to local${NC}"
echo ""

# Verify import
echo "🔍 Verifying import..."
TABLE_COUNT=$(psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
echo -e "${GREEN}✅ Import verification: $TABLE_COUNT tables found${NC}"

# Show table list
echo ""
echo "📋 Tables in local database:"
psql -h "$LOCAL_DB_HOST" -p "$LOCAL_DB_PORT" -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"

echo ""

# Clean up temporary file
rm -f "$BACKUP_FILE.modified"

# Update local .env file
echo "⚙️  Updating local environment configuration..."
LOCAL_ENV_FILE=".env.development"
if [ -f "$LOCAL_ENV_FILE" ]; then
    # Update DATABASE_URL in local env file
    sed -i.bak "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://$LOCAL_DB_USER:$LOCAL_DB_PASSWORD@$LOCAL_DB_HOST:$LOCAL_DB_PORT/$LOCAL_DB_NAME|" "$LOCAL_ENV_FILE"
    echo -e "${GREEN}✅ Updated $LOCAL_ENV_FILE${NC}"
    rm -f "$LOCAL_ENV_FILE.bak"
else
    echo -e "${YELLOW}⚠️  $LOCAL_ENV_FILE not found, creating it...${NC}"
    cat > "$LOCAL_ENV_FILE" << EOF
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

# Add your other environment variables here...
EOF
    echo -e "${GREEN}✅ Created $LOCAL_ENV_FILE${NC}"
fi

echo ""
echo "======================================"
echo -e "${GREEN}🎉 Sync Complete!${NC}"
echo "======================================"
echo ""
echo "📊 Summary:"
echo "  ✅ Production database exported"
echo "  ✅ Local database recreated"
echo "  ✅ Production data imported"
echo "  ✅ Local environment updated"
echo ""
echo "📁 Files created:"
echo "  📦 Production backup: $BACKUP_FILE"
if [ -f "$LOCAL_BACKUP_FILE" ]; then
    echo "  📦 Local backup: $LOCAL_BACKUP_FILE"
fi
echo ""
echo "🚀 Next steps:"
echo "  1. Run: npm install"
echo "  2. Run: npm run dev"
echo "  3. Verify your app works with production data"
echo ""
echo -e "${BLUE}💡 Tip: Run this script regularly to keep local in sync with production${NC}"
echo ""
