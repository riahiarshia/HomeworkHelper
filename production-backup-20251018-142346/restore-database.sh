#!/bin/bash

# ========================================
# Database Restore Script
# ========================================
# Usage: ./restore-database.sh [environment] [backup_file]

set -e

ENVIRONMENT=$1
BACKUP_FILE=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./restore-database.sh [development|staging|production] [backup_file]"
    exit 1
fi

echo "╔═══════════════════════════════════════════════════╗"
echo "║   ⚠️  Database Restore - $ENVIRONMENT"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  WARNING: This will OVERWRITE the current database!${NC}"
echo ""
echo "Backup file: $BACKUP_FILE"
echo "Target environment: $ENVIRONMENT"
echo ""
read -p "Type 'YES' to confirm restore: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Restore cancelled."
    exit 1
fi

# Get database URL
case $ENVIRONMENT in
  development)
    DB_URL="postgresql://postgres:dev_password_123@localhost:5432/homework_helper_dev"
    ;;
  staging|production)
    echo "Enter $ENVIRONMENT database URL:"
    read -s DB_URL
    ;;
  *)
    echo -e "${RED}Invalid environment${NC}"
    exit 1
    ;;
esac

echo ""
echo "Restoring database..."

# Drop existing connections
psql "$DB_URL" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = current_database() AND pid <> pg_backend_pid();" || true

# Restore
pg_restore -d "$DB_URL" --clean --if-exists "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Database restored successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Verify data integrity"
    echo "  2. Restart application"
    echo "  3. Run health checks"
else
    echo -e "${RED}❌ Restore failed!${NC}"
    exit 1
fi

