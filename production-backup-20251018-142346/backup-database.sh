#!/bin/bash

# Comprehensive Database Backup Script
# This script creates a complete backup of the production database

echo "🗄️  CREATING COMPREHENSIVE DATABASE BACKUP"
echo "=========================================="
echo ""

BACKUP_DIR="/Users/ar616n/Documents/homeworkhelper_goodbackups/$(ls -td ~/Documents/homeworkhelper_goodbackups/*/ | head -1 | sed 's|.*/||' | sed 's|/$||')"
DB_BACKUP_DIR="$BACKUP_DIR/database"

# Create database backup directory
mkdir -p "$DB_BACKUP_DIR"

echo "📁 Backup directory: $BACKUP_DIR"
echo "📁 Database backup directory: $DB_BACKUP_DIR"
echo ""

# Get database credentials from Azure Key Vault
echo "🔑 Getting database credentials from Azure Key Vault..."
DB_PASSWORD=$(az keyvault secret show --vault-name OpenAI-1 --name DATABASE-PASSWORD --query 'value' -o tsv)
DB_HOST="homework-helper-db.postgres.database.azure.com"
DB_NAME="homework_helper"
DB_USER="homework_helper_user"
DB_PORT="5432"

# Construct database URL
DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"

echo "✅ Database credentials retrieved"
echo "   Host: $DB_HOST"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"
echo ""

# 1. Full database dump (schema + data)
echo "📊 Creating full database dump..."
pg_dump "$DATABASE_URL" \
    --verbose \
    --clean \
    --no-owner \
    --no-privileges \
    --format=custom \
    --file="$DB_BACKUP_DIR/homework_helper_full_backup.dump"

if [ $? -eq 0 ]; then
    echo "✅ Full database dump created: homework_helper_full_backup.dump"
else
    echo "❌ Failed to create full database dump"
    exit 1
fi

# 2. Schema-only backup
echo "📋 Creating schema-only backup..."
pg_dump "$DATABASE_URL" \
    --verbose \
    --schema-only \
    --no-owner \
    --no-privileges \
    --format=plain \
    --file="$DB_BACKUP_DIR/schema_only.sql"

if [ $? -eq 0 ]; then
    echo "✅ Schema-only backup created: schema_only.sql"
else
    echo "❌ Failed to create schema-only backup"
    exit 1
fi

# 3. Data-only backup
echo "📈 Creating data-only backup..."
pg_dump "$DATABASE_URL" \
    --verbose \
    --data-only \
    --no-owner \
    --no-privileges \
    --format=plain \
    --file="$DB_BACKUP_DIR/data_only.sql"

if [ $? -eq 0 ]; then
    echo "✅ Data-only backup created: data_only.sql"
else
    echo "❌ Failed to create data-only backup"
    exit 1
fi

# 4. Create a readable SQL dump
echo "📝 Creating readable SQL dump..."
pg_dump "$DATABASE_URL" \
    --verbose \
    --clean \
    --no-owner \
    --no-privileges \
    --format=plain \
    --file="$DB_BACKUP_DIR/homework_helper_readable.sql"

if [ $? -eq 0 ]; then
    echo "✅ Readable SQL dump created: homework_helper_readable.sql"
else
    echo "❌ Failed to create readable SQL dump"
    exit 1
fi

# 5. Backup specific important tables individually
echo "🗂️  Creating individual table backups..."

# List of important tables
TABLES=("users" "admin_users" "homework_submissions" "usage_tracking" "monthly_usage" "device_tracking")

for table in "${TABLES[@]}"; do
    echo "   Backing up table: $table"
    pg_dump "$DATABASE_URL" \
        --verbose \
        --table="$table" \
        --data-only \
        --no-owner \
        --no-privileges \
        --format=plain \
        --file="$DB_BACKUP_DIR/table_${table}.sql"
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Table $table backed up successfully"
    else
        echo "   ⚠️  Warning: Failed to backup table $table (might not exist)"
    fi
done

# 6. Get database statistics
echo "📊 Creating database statistics..."
psql "$DATABASE_URL" -c "
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE schemaname = 'public'
ORDER BY tablename, attname;
" > "$DB_BACKUP_DIR/database_statistics.txt"

# 7. Get table sizes
echo "📏 Recording table sizes..."
psql "$DATABASE_URL" -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    pg_total_relation_size(schemaname||'.'||tablename) as size_bytes
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
" > "$DB_BACKUP_DIR/table_sizes.txt"

# 8. Create backup metadata
echo "📋 Creating backup metadata..."
cat > "$DB_BACKUP_DIR/backup_metadata.txt" << EOF
Homework Helper Database Backup
==============================

Backup Date: $(date)
Backup Type: Full Production Database Backup
Database Host: $DB_HOST
Database Name: $DB_NAME
Database User: $DB_USER

Backup Contents:
- Full database dump (custom format): homework_helper_full_backup.dump
- Schema only: schema_only.sql
- Data only: data_only.sql
- Readable SQL dump: homework_helper_readable.sql
- Individual table backups: table_*.sql
- Database statistics: database_statistics.txt
- Table sizes: table_sizes.txt

Restore Instructions:
1. For full restore: pg_restore -d NEW_DATABASE_URL homework_helper_full_backup.dump
2. For schema only: psql NEW_DATABASE_URL < schema_only.sql
3. For data only: psql NEW_DATABASE_URL < data_only.sql
4. For readable restore: psql NEW_DATABASE_URL < homework_helper_readable.sql

File Sizes:
EOF

# Add file sizes to metadata
ls -lh "$DB_BACKUP_DIR"/*.dump "$DB_BACKUP_DIR"/*.sql >> "$DB_BACKUP_DIR/backup_metadata.txt" 2>/dev/null

echo "✅ Backup metadata created: backup_metadata.txt"
echo ""

# Summary
echo "🎉 DATABASE BACKUP COMPLETED SUCCESSFULLY!"
echo "=========================================="
echo ""
echo "📁 Backup location: $DB_BACKUP_DIR"
echo ""
echo "📊 Backup files created:"
ls -lh "$DB_BACKUP_DIR"/*.dump "$DB_BACKUP_DIR"/*.sql "$DB_BACKUP_DIR"/*.txt 2>/dev/null
echo ""
echo "💾 Total backup size:"
du -sh "$DB_BACKUP_DIR"
echo ""
echo "✅ Database backup is complete and ready for restoration!"