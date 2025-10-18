#!/bin/bash

# Deploy homework tracking feature to Azure
# This script applies the homework tracking migration and deploys the updated backend

set -e  # Exit on error

echo "🚀 Deploying Homework Tracking Feature to Azure"
echo "=============================================="

# Load environment variables
if [ -f .env ]; then
    source .env
    echo "✅ Loaded environment variables from .env"
else
    echo "⚠️  No .env file found, using environment variables"
fi

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "❌ ERROR: DATABASE_URL environment variable is not set"
    exit 1
fi

echo ""
echo "📊 Step 1: Applying database migration..."
echo "----------------------------------------"

# Apply migration using psql
psql "$DATABASE_URL" -f migrations/005_add_homework_tracking.sql

if [ $? -eq 0 ]; then
    echo "✅ Migration applied successfully!"
else
    echo "❌ Migration failed!"
    exit 1
fi

echo ""
echo "🔍 Step 2: Verifying migration..."
echo "----------------------------------------"

# Verify the migration by checking if the tables exist
VERIFY_QUERY="SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'homework_submissions'
) AND EXISTS (
    SELECT FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'total_homework_submissions'
);"

RESULT=$(psql "$DATABASE_URL" -t -c "$VERIFY_QUERY")

if [[ $RESULT == *"t"* ]]; then
    echo "✅ Migration verified! Tables and columns exist."
else
    echo "❌ Migration verification failed!"
    exit 1
fi

echo ""
echo "📦 Step 3: Deploying to Azure..."
echo "----------------------------------------"

# Deploy to Azure (assuming you're using Azure App Service)
# Uncomment and modify based on your deployment method

# Option 1: Using Azure CLI
# az webapp deployment source config-zip --resource-group <your-resource-group> --name <your-app-name> --src <path-to-zip>

# Option 2: Using Git
# git add .
# git commit -m "Add homework tracking feature"
# git push azure main

# Option 3: Manual note
echo "⚠️  Please deploy the backend to Azure using your preferred method:"
echo "   - Azure CLI: az webapp deployment source config-zip ..."
echo "   - Git: git push azure main"
echo "   - GitHub Actions: Push to your repository"

echo ""
echo "✅ Migration complete! Backend is ready to track homework submissions."
echo ""
echo "📊 Next steps:"
echo "   1. Deploy the iOS app with updated BackendAPIService"
echo "   2. Test homework submission tracking"
echo "   3. Check admin dashboard for homework stats"
echo ""
echo "📝 API Endpoints available:"
echo "   POST   /api/homework/submit - Track homework submission"
echo "   PUT    /api/homework/complete/:problemId - Update completion"
echo "   GET    /api/homework/stats - Get user stats"
echo "   GET    /api/homework/admin/submissions - Get all submissions (admin)"
echo "   GET    /api/homework/admin/stats/:userId - Get user stats (admin)"

