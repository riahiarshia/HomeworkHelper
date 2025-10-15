#!/bin/bash

# Copy Production Database to Staging
# This script dumps the production database and restores it to staging

set -e

echo "🚀 Starting production to staging database copy..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Get connection strings from Azure App Service configurations
print_info "🔍 Getting database connection strings from Azure..."

# Get production database connection string
PROD_CONNECTION_STRING=$(az webapp config appsettings list \
    --resource-group homework-helper-rg-f \
    --name homework-helper-api \
    --query "[?name=='DATABASE_URL'].value" \
    --output tsv)

if [ -z "$PROD_CONNECTION_STRING" ]; then
    print_error "Could not get production DATABASE_URL from Azure App Service"
    exit 1
fi

# Get staging database connection string  
STAGING_CONNECTION_STRING=$(az webapp config appsettings list \
    --resource-group homework-helper-stage-rg-f \
    --name homework-helper-staging \
    --query "[?name=='DATABASE_URL'].value" \
    --output tsv)

if [ -z "$STAGING_CONNECTION_STRING" ]; then
    print_error "Could not get staging DATABASE_URL from Azure App Service"
    exit 1
fi

print_status "✅ Got connection strings from Azure App Service"

# Create backup directory
BACKUP_DIR="./database-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

print_info "📁 Backup directory: $BACKUP_DIR"

# Step 1: Dump production database schema
print_info "📊 Dumping production database schema..."
pg_dump \
    "$PROD_CONNECTION_STRING" \
    --schema-only \
    --no-owner \
    --no-privileges \
    --file="$BACKUP_DIR/production-schema.sql"

if [ $? -eq 0 ]; then
    print_status "Production schema dumped successfully"
else
    print_error "Failed to dump production schema"
    exit 1
fi

# Step 2: Dump production database data
print_info "📊 Dumping production database data..."
pg_dump \
    "$PROD_CONNECTION_STRING" \
    --data-only \
    --no-owner \
    --no-privileges \
    --file="$BACKUP_DIR/production-data.sql"

if [ $? -eq 0 ]; then
    print_status "Production data dumped successfully"
else
    print_error "Failed to dump production data"
    exit 1
fi

# Step 3: Drop all tables in staging database (WARNING!)
print_warning "⚠️  This will DELETE ALL DATA in staging database!"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    print_error "Operation cancelled by user"
    exit 1
fi

print_info "🗑️  Dropping all tables in staging database..."

# Get list of tables to drop
TABLES=$(psql \
    "$STAGING_CONNECTION_STRING" \
    --tuples-only \
    --no-align \
    --command="SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

# Drop tables (in reverse dependency order)
for table in $(echo "$TABLES" | tac); do
    if [ ! -z "$table" ]; then
        print_info "Dropping table: $table"
        psql \
            "$STAGING_CONNECTION_STRING" \
            --command="DROP TABLE IF EXISTS \"$table\" CASCADE;"
    fi
done

print_status "All staging tables dropped"

# Step 4: Restore schema to staging
print_info "📊 Restoring schema to staging database..."
psql \
    "$STAGING_CONNECTION_STRING" \
    --file="$BACKUP_DIR/production-schema.sql"

if [ $? -eq 0 ]; then
    print_status "Schema restored to staging successfully"
else
    print_error "Failed to restore schema to staging"
    exit 1
fi

# Step 5: Restore data to staging
print_info "📊 Restoring data to staging database..."
psql \
    "$STAGING_CONNECTION_STRING" \
    --file="$BACKUP_DIR/production-data.sql"

if [ $? -eq 0 ]; then
    print_status "Data restored to staging successfully"
else
    print_error "Failed to restore data to staging"
    exit 1
fi

# Step 6: Verify the copy
print_info "🔍 Verifying database copy..."

PROD_TABLES=$(psql \
    "$PROD_CONNECTION_STRING" \
    --tuples-only \
    --no-align \
    --command="SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public';")

STAGING_TABLES=$(psql \
    "$STAGING_CONNECTION_STRING" \
    --tuples-only \
    --no-align \
    --command="SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public';")

print_info "Production tables: $PROD_TABLES"
print_info "Staging tables: $STAGING_TABLES"

if [ "$PROD_TABLES" = "$STAGING_TABLES" ]; then
    print_status "✅ Table counts match!"
else
    print_warning "⚠️  Table counts don't match - please verify manually"
fi

# Step 7: Clean up backup files (optional)
read -p "Delete backup files? (yes/no): " DELETE_BACKUP
if [ "$DELETE_BACKUP" = "yes" ]; then
    rm -rf "$BACKUP_DIR"
    print_status "Backup files deleted"
else
    print_info "Backup files kept in: $BACKUP_DIR"
fi

echo ""
print_status "🎉 Production to staging database copy completed!"
print_info "📊 Staging database now contains exact copy of production"
print_info "🔧 You can now test with production data in staging environment"

echo ""
print_info "Next steps:"
print_info "1. Test iOS app with staging backend"
print_info "2. Verify all functionality works"
print_info "3. Check admin portal access"
