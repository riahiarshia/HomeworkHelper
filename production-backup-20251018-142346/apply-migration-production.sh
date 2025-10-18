#!/bin/bash

# ========================================
# Safe Production Migration Script
# ========================================
# Usage: ./apply-migration-production.sh [migration_file.sql]

set -e

MIGRATION_FILE=$1

if [ -z "$MIGRATION_FILE" ]; then
    echo "Usage: ./apply-migration-production.sh [migration_file.sql]"
    echo "Example: ./apply-migration-production.sh backend/migrations/007_add_premium_tier.sql"
    exit 1
fi

echo "╔══════════════════════════════════════════════════════╗"
echo "║   🚨 PRODUCTION DATABASE MIGRATION                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if migration file exists
if [ ! -f "$MIGRATION_FILE" ]; then
    echo -e "${RED}❌ Migration file not found: $MIGRATION_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}Migration file: $MIGRATION_FILE${NC}"
echo ""
echo "Contents:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -20 "$MIGRATION_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Safety Checks
echo -e "${YELLOW}🔍 Running safety checks...${NC}"
echo ""

# Check for dangerous commands
DANGEROUS_COMMANDS="DROP TABLE|DROP DATABASE|TRUNCATE|DELETE FROM"
if grep -Ei "$DANGEROUS_COMMANDS" "$MIGRATION_FILE" | grep -v "^--" > /dev/null; then
    echo -e "${RED}⚠️  WARNING: Migration contains potentially dangerous commands!${NC}"
    grep -Eni "$DANGEROUS_COMMANDS" "$MIGRATION_FILE" | grep -v "^--"
    echo ""
    read -p "Are you ABSOLUTELY SURE you want to continue? (type 'DANGEROUS'): " CONFIRM
    if [ "$CONFIRM" != "DANGEROUS" ]; then
        echo "Migration cancelled."
        exit 1
    fi
fi

# Check for BEGIN/COMMIT (transaction safety)
if ! grep -i "BEGIN" "$MIGRATION_FILE" > /dev/null; then
    echo -e "${YELLOW}⚠️  Migration doesn't have explicit transaction (BEGIN/COMMIT)${NC}"
    read -p "Continue anyway? (y/N): " CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
        echo "Migration cancelled."
        exit 1
    fi
fi

echo -e "${GREEN}✅ Safety checks passed${NC}"
echo ""

# Get production database URL
echo -e "${YELLOW}⚠️  PRODUCTION DATABASE${NC}"
echo "Enter production database URL:"
read -s DB_URL
echo ""

# Verify this is production
echo "Verifying connection..."
DB_NAME=$(psql "$DB_URL" -tAc "SELECT current_database();")
echo "Database: $DB_NAME"
echo ""

read -p "Is this correct? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 1
fi

# Step 1: Backup
echo ""
echo -e "${BLUE}Step 1: Creating backup...${NC}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/production"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/pre_migration_${TIMESTAMP}.dump"

pg_dump "$DB_URL" -Fc -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}✅ Backup created: $BACKUP_FILE ($BACKUP_SIZE)${NC}"
else
    echo -e "${RED}❌ Backup failed! Aborting migration.${NC}"
    exit 1
fi

# Step 2: Test migration on backup (dry run)
echo ""
echo -e "${BLUE}Step 2: Testing migration (dry run)...${NC}"

# Create temporary test database
TEST_DB="homework_helper_migration_test_$$"
createdb -T template0 "$TEST_DB" 2>/dev/null || true
pg_restore -d "$TEST_DB" --no-owner "$BACKUP_FILE" 2>/dev/null

# Try migration on test database
psql -d "$TEST_DB" -f "$MIGRATION_FILE" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dry run successful${NC}"
    dropdb "$TEST_DB" 2>/dev/null
else
    echo -e "${RED}❌ Dry run failed! Check migration syntax.${NC}"
    dropdb "$TEST_DB" 2>/dev/null
    exit 1
fi

# Step 3: Apply to production
echo ""
echo -e "${BLUE}Step 3: Applying migration to PRODUCTION...${NC}"
echo ""
echo -e "${YELLOW}⚠️  FINAL CONFIRMATION${NC}"
echo "This will modify the PRODUCTION database!"
echo ""
read -p "Type 'APPLY' to proceed: " FINAL_CONFIRM

if [ "$FINAL_CONFIRM" != "APPLY" ]; then
    echo "Migration cancelled."
    echo "Backup preserved at: $BACKUP_FILE"
    exit 1
fi

echo ""
echo "Applying migration..."

# Apply migration with output
psql "$DB_URL" -f "$MIGRATION_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ Migration applied successfully!              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Backup location: $BACKUP_FILE"
    echo "To rollback: ./restore-database.sh production $BACKUP_FILE"
    echo ""
    echo "Next steps:"
    echo "  1. Verify database integrity"
    echo "  2. Deploy matching application code"
    echo "  3. Monitor for issues"
    echo "  4. Keep backup for 30 days"
else
    echo ""
    echo -e "${RED}❌ Migration failed!${NC}"
    echo ""
    echo "To rollback:"
    echo "  ./restore-database.sh production $BACKUP_FILE"
    exit 1
fi

# Step 4: Log migration
echo ""
echo "Logging migration..."
MIGRATION_NAME=$(basename "$MIGRATION_FILE" .sql)
psql "$DB_URL" -c "
INSERT INTO migration_log (migration_name, applied_at, notes) 
VALUES ('$MIGRATION_NAME', NOW(), 'Applied via apply-migration-production.sh')
ON CONFLICT (migration_name) DO NOTHING;
" 2>/dev/null || echo "Note: migration_log table not found (optional)"

echo ""
echo -e "${GREEN}✅ Migration complete!${NC}"

