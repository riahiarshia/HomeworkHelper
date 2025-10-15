#!/bin/bash

# ========================================
# Database Backup Script
# ========================================
# Usage: ./backup-database.sh [development|staging|production]

set -e

ENVIRONMENT=${1:-staging}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "╔═══════════════════════════════════════════════════╗"
echo "║   💾 Database Backup - $ENVIRONMENT"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Set database URL based on environment
case $ENVIRONMENT in
  development)
    DB_URL="postgresql://postgres:dev_password_123@localhost:5432/homework_helper_dev"
    BACKUP_DIR="./backups/dev"
    ;;
  staging)
    echo "Enter staging database URL:"
    read -s DB_URL
    BACKUP_DIR="./backups/staging"
    ;;
  production)
    echo -e "${YELLOW}⚠️  PRODUCTION DATABASE BACKUP${NC}"
    echo "Enter production database URL:"
    read -s DB_URL
    BACKUP_DIR="./backups/production"
    ;;
  *)
    echo -e "${RED}Invalid environment: $ENVIRONMENT${NC}"
    echo "Usage: ./backup-database.sh [development|staging|production]"
    exit 1
    ;;
esac

# Create backup directory
mkdir -p "$BACKUP_DIR"

BACKUP_FILE="$BACKUP_DIR/backup_${ENVIRONMENT}_${TIMESTAMP}.dump"

echo ""
echo "Creating backup..."
echo "  Environment: $ENVIRONMENT"
echo "  File: $BACKUP_FILE"
echo ""

# Create compressed backup
pg_dump "$DB_URL" -Fc -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}✅ Backup created successfully!${NC}"
    echo ""
    echo "Backup details:"
    echo "  File: $BACKUP_FILE"
    echo "  Size: $BACKUP_SIZE"
    echo "  Timestamp: $TIMESTAMP"
    echo ""
    
    # Also create human-readable SQL version
    SQL_FILE="$BACKUP_DIR/backup_${ENVIRONMENT}_${TIMESTAMP}.sql"
    pg_dump "$DB_URL" -f "$SQL_FILE"
    SQL_SIZE=$(du -h "$SQL_FILE" | cut -f1)
    echo "  SQL File: $SQL_FILE"
    echo "  SQL Size: $SQL_SIZE"
    echo ""
    
    # Verify backup integrity
    echo "Verifying backup integrity..."
    pg_restore --list "$BACKUP_FILE" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Backup verified - integrity OK${NC}"
    else
        echo -e "${RED}❌ Backup verification failed!${NC}"
        exit 1
    fi
    
    echo ""
    echo "To restore this backup:"
    echo "  ./restore-database.sh $ENVIRONMENT $BACKUP_FILE"
    echo ""
    
    # Clean up old backups (keep last 10)
    echo "Cleaning up old backups (keeping last 10)..."
    cd "$BACKUP_DIR"
    ls -t backup_${ENVIRONMENT}_*.dump | tail -n +11 | xargs -r rm
    ls -t backup_${ENVIRONMENT}_*.sql | tail -n +11 | xargs -r rm
    cd - > /dev/null
    
    echo -e "${GREEN}✅ Backup complete!${NC}"
else
    echo -e "${RED}❌ Backup failed!${NC}"
    exit 1
fi

