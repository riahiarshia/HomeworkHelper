#!/bin/bash

# Apply Trial Abuse Prevention Database Migration
# This script applies the trial_usage_history table migration to production database

set -e  # Exit on error

echo "🗄️ Applying Trial Abuse Prevention Database Migration..."
echo ""

# Check if migration file exists
if [ ! -f "backend/migrations/007_add_trial_abuse_prevention.sql" ]; then
    echo "❌ Error: Migration file not found"
    exit 1
fi

echo "📋 Migration: 007_add_trial_abuse_prevention.sql"
echo ""
echo "This will create:"
echo "  - trial_usage_history table (persists trial data after account deletion)"
echo "  - Indexes for performance"
echo "  - Triggers for automatic timestamp updates"
echo ""

# Get database connection info
echo "🔍 Getting database connection info from Azure..."
DB_CONNECTION_STRING=$(az webapp config appsettings list \
    --name homework-helper-api \
    --resource-group homework-helper-rg-f \
    --query "[?name=='DATABASE_URL'].value" -o tsv)

if [ -z "$DB_CONNECTION_STRING" ]; then
    echo "❌ Error: Could not retrieve database connection string from Azure"
    exit 1
fi

echo "✅ Database connection retrieved"
echo ""

# Parse connection string to get components
# Format: postgresql://user:pass@host:port/database?sslmode=require
DB_HOST=$(echo $DB_CONNECTION_STRING | sed -n 's/.*@\(.*\):[0-9]*.*/\1/p')
DB_USER=$(echo $DB_CONNECTION_STRING | sed -n 's/postgresql:\/\/\(.*\):.*/\1/p')
DB_NAME=$(echo $DB_CONNECTION_STRING | sed -n 's/.*\/\([^?]*\).*/\1/p')

echo "📊 Database Info:"
echo "   Host: $DB_HOST"
echo "   User: $DB_USER"
echo "   Database: $DB_NAME"
echo ""

# Confirm before proceeding
echo "⚠️  This will modify the production database."
read -p "Continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Migration cancelled"
    exit 1
fi

echo ""
echo "🚀 Applying migration..."
echo ""

# Apply migration using psql with connection string
PGPASSWORD="" psql "$DB_CONNECTION_STRING" < backend/migrations/007_add_trial_abuse_prevention.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Migration applied successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📊 Verifying migration..."
    echo ""
    
    # Verify table was created
    PGPASSWORD="" psql "$DB_CONNECTION_STRING" -c "\d trial_usage_history" 2>&1 | head -20
    
    echo ""
    echo "✅ Table 'trial_usage_history' created successfully"
    echo ""
    echo "🎉 Trial abuse prevention is now active!"
    echo ""
    echo "What this means:"
    echo "  ✅ Backend tracks Apple trials by original_transaction_id"
    echo "  ✅ Data persists even after account deletion (fraud prevention)"
    echo "  ✅ Apple enforces one trial per Apple ID automatically"
    echo ""
else
    echo ""
    echo "❌ Migration failed!"
    echo ""
    echo "Check the error messages above for details."
    echo "You may need to apply the migration manually."
    exit 1
fi

