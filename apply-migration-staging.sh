#!/bin/bash

# ========================================
# Staging Migration Script
# ========================================
# Simpler than production - still safe but less ceremony

MIGRATION_FILE=$1

if [ -z "$MIGRATION_FILE" ]; then
    echo "Usage: ./apply-migration-staging.sh [migration_file.sql]"
    exit 1
fi

echo "🧪 Applying migration to STAGING..."
echo ""

GREEN='\033[0;32m'
NC='\033[0m'

# Backup first
./backup-database.sh staging

# Get database URL
echo "Enter staging database URL:"
read -s DB_URL

# Apply migration
psql "$DB_URL" -f "$MIGRATION_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Migration applied to staging${NC}"
    echo ""
    echo "Test thoroughly before applying to production!"
else
    echo "❌ Migration failed!"
    exit 1
fi

