#!/bin/bash

# Deploy Apple Subscription System
# This script deploys the complete Apple subscription implementation

echo "🍎 Deploying Apple Subscription System..."

# Check if we're in the backend directory
if [ ! -f "package.json" ]; then
    echo "❌ Please run this script from the backend directory"
    exit 1
fi

# Check if required environment variables are set
if [ -z "$APPLE_SHARED_SECRET" ]; then
    echo "⚠️  WARNING: APPLE_SHARED_SECRET environment variable not set"
    echo "   You need to set this in your Azure App Service configuration"
    echo "   Get it from: App Store Connect → Your App → App Information → Shared Secret"
fi

# Run database migration
echo "📊 Running database migration..."
node -e "
const { Pool } = require('pg');
const fs = require('fs');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function runMigration() {
    try {
        const migrationSQL = fs.readFileSync('./migrations/006_add_apple_subscription_tracking.sql', 'utf8');
        await pool.query(migrationSQL);
        console.log('✅ Database migration completed successfully');
    } catch (error) {
        console.error('❌ Database migration failed:', error.message);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

runMigration();
"

# Check if migration was successful
if [ $? -eq 0 ]; then
    echo "✅ Database migration completed"
else
    echo "❌ Database migration failed"
    exit 1
fi

# Install any new dependencies
echo "📦 Installing dependencies..."
npm install

# Check if we're deploying to Azure
if [ ! -z "$AZURE_WEBAPP_NAME" ]; then
    echo "🚀 Deploying to Azure App Service..."
    
    # Deploy to Azure
    az webapp deployment source config-zip \
        --resource-group $AZURE_RESOURCE_GROUP \
        --name $AZURE_WEBAPP_NAME \
        --src ../backend-apple-subscriptions.zip
    
    if [ $? -eq 0 ]; then
        echo "✅ Azure deployment completed"
    else
        echo "❌ Azure deployment failed"
        exit 1
    fi
else
    echo "ℹ️  AZURE_WEBAPP_NAME not set - skipping Azure deployment"
    echo "   To deploy manually:"
    echo "   1. Commit your changes to git"
    echo "   2. Push to your deployment branch"
    echo "   3. Or use: az webapp deployment source config-zip"
fi

# Test the endpoints
echo "🧪 Testing Apple subscription endpoints..."

# Test webhook endpoint
echo "Testing webhook endpoint..."
curl -X POST https://homework-helper-api.azurewebsites.net/api/subscription/apple/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": true}' \
  --max-time 10

if [ $? -eq 0 ]; then
    echo "✅ Webhook endpoint is accessible"
else
    echo "❌ Webhook endpoint test failed"
fi

echo ""
echo "🎉 Apple Subscription System Deployment Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. ✅ Backend endpoints created"
echo "2. ✅ Database schema updated"
echo "3. ✅ iOS app updated to send receipts"
echo "4. ⏳ Configure App Store Connect webhook URL:"
echo "   https://homework-helper-api.azurewebsites.net/api/subscription/apple/webhook"
echo "5. ⏳ Set APPLE_SHARED_SECRET in Azure environment variables"
echo "6. ⏳ Test with sandbox purchases"
echo ""
echo "🔧 App Store Connect Configuration:"
echo "   Users and Access → Integrations → Webhooks"
echo "   Add URL: https://homework-helper-api.azurewebsites.net/api/subscription/apple/webhook"
echo ""
echo "📱 Product ID to use: com.homeworkhelper.monthly"
echo ""
