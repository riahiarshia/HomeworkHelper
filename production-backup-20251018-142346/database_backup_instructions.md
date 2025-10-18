# Database Backup Instructions

## Manual Database Backup Required

The database backup requires manual execution with proper credentials. Here are the steps:

### Option 1: Using the backup script (requires password)
```bash
cd production-backup-20251018-142346/database
./backup-database.sh
```

### Option 2: Manual database export
```bash
# Get database password from Azure Key Vault or environment
export DB_PASSWORD="your_database_password"

# Create database backup
pg_dump "postgresql://homework_helper_user:$DB_PASSWORD@homework-helper-db.postgres.database.azure.com:5432/homework_helper" \
    --verbose \
    --clean \
    --no-owner \
    --no-privileges \
    --format=custom \
    --file="homework_helper_full_backup.dump"

# Create readable SQL dump
pg_dump "postgresql://homework_helper_user:$DB_PASSWORD@homework-helper-db.postgres.database.azure.com:5432/homework_helper" \
    --verbose \
    --clean \
    --no-owner \
    --no-privileges \
    --format=plain \
    --file="homework_helper_readable.sql"
```

### Option 3: Azure Portal Export
1. Go to Azure Portal
2. Navigate to your PostgreSQL database
3. Use "Export" feature to create database backup
4. Download and place in this directory

## Database Connection Details
- Host: homework-helper-db.postgres.database.azure.com
- Database: homework_helper
- User: homework_helper_user
- Port: 5432
- Password: (retrieve from Azure Key Vault or environment variables)

## Important Tables to Backup
- users
- admin_users
- homework_submissions
- usage_tracking
- monthly_usage
- device_tracking
- entitlements_ledger
- subscription_data

## Restore Instructions
```bash
# Restore from custom format
pg_restore -d "NEW_DATABASE_URL" homework_helper_full_backup.dump

# Restore from SQL dump
psql "NEW_DATABASE_URL" < homework_helper_readable.sql
```
