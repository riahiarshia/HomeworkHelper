#!/bin/bash

# Deploy Monthly Usage Reset Feature
# This script applies the monthly usage reset migration and deploys the updated backend

echo "🚀 Deploying Monthly Usage Reset Feature..."

# Apply database migration
echo "📊 Applying database migration..."
psql $DATABASE_URL -f database/monthly-usage-reset-migration.sql

if [ $? -eq 0 ]; then
    echo "✅ Database migration applied successfully!"
else
    echo "❌ Database migration failed!"
    exit 1
fi

# Create deployment package
echo "📦 Creating deployment package..."
zip -r monthly-usage-reset-backend.zip . -x "*.git*" "node_modules/*" "*.log" "*.zip"

if [ $? -eq 0 ]; then
    echo "✅ Deployment package created!"
else
    echo "❌ Failed to create deployment package!"
    exit 1
fi

# Deploy to Azure
echo "☁️ Deploying to Azure..."
az webapp deploy --name homework-helper-api --resource-group homework-helper-rg-f --src-path monthly-usage-reset-backend.zip

if [ $? -eq 0 ]; then
    echo "✅ Successfully deployed to Azure!"
else
    echo "❌ Azure deployment failed!"
    exit 1
fi

echo ""
echo "🎉 Monthly Usage Reset Feature Deployed Successfully!"
echo ""
echo "📊 What's New:"
echo "   ✅ Monthly usage reset on subscription renewal"
echo "   ✅ Monthly cost tracking per user"
echo "   ✅ Admin portal monthly costs view"
echo "   ✅ Historical data preservation"
echo ""
echo "📈 New Admin Portal Endpoints:"
echo "   • GET /api/admin/monthly-costs"
echo "   • GET /api/admin/user-monthly-usage/:userId"
echo ""
echo "🔧 How it works:"
echo "   1. Users make API calls → tracked in user_api_usage"
echo "   2. Usage also tracked in monthly_usage_summary"
echo "   3. On subscription renewal → monthly tracking resets"
echo "   4. Admin portal shows monthly costs per user"
echo ""
echo "🎯 Benefits:"
echo "   • Fair billing - fresh start each month"
echo "   • Cost visibility - see monthly costs per user"
echo "   • Better analytics - monthly vs lifetime tracking"
echo "   • Happy users - no lifetime usage penalties"
echo ""
echo "📱 Test the feature:"
echo "   1. Make some API calls in your app"
echo "   2. Check admin portal for monthly costs"
echo "   3. Simulate subscription renewal"
echo "   4. Verify usage tracking resets"
echo ""

# Clean up
rm monthly-usage-reset-backend.zip
echo "🧹 Cleaned up temporary files"
echo "✅ Deployment complete!"


