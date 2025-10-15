#!/bin/bash

# Deploy Trial Abuse Prevention Changes
# This script deploys the updated backend with Apple trial enforcement

set -e  # Exit on error

echo "🚀 Deploying Trial Abuse Prevention Update..."
echo ""

# Step 1: Check we're in the right directory
if [ ! -f "server.js" ]; then
    echo "❌ Error: Must run from backend directory"
    exit 1
fi

# Step 2: Create deployment package
echo "📦 Creating deployment package..."
zip -r backend-trial-prevention.zip . \
    -x "node_modules/*" \
    -x ".git/*" \
    -x "*.zip" \
    -x ".DS_Store" \
    -x "*.log"

echo "✅ Package created: backend-trial-prevention.zip"
echo ""

# Step 3: Deploy to Azure
echo "☁️ Deploying to Azure App Service..."
az webapp deployment source config-zip \
    --resource-group homework-helper-rg-f \
    --name homework-helper-api \
    --src backend-trial-prevention.zip

echo ""
echo "✅ Deployment complete!"
echo ""
echo "⏳ Waiting for Azure to restart (30 seconds)..."
sleep 30
echo ""

# Step 4: Test the deployment
echo "🧪 Testing deployed endpoints..."
echo ""

# Test health endpoint
echo "1. Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s https://homework-helper-api.azurewebsites.net/api/health || echo "FAILED")
if [[ $HEALTH_RESPONSE == *"ok"* ]]; then
    echo "   ✅ Health check passed"
else
    echo "   ⚠️ Health check warning: $HEALTH_RESPONSE"
fi
echo ""

# Test that new signup returns expired status
echo "2. Testing signup flow (should return expired status)..."
SIGNUP_TEST=$(curl -s -X POST https://homework-helper-api.azurewebsites.net/api/auth/google \
    -H "Content-Type: application/json" \
    -d '{
        "email": "test-deployment-'$(date +%s)'@example.com",
        "name": "Test User",
        "googleIdToken": "test_token_'$(date +%s)'"
    }' 2>&1 || echo "FAILED")

if [[ $SIGNUP_TEST == *"expired"* ]]; then
    echo "   ✅ New users correctly get expired status (no auto-trial)"
else
    echo "   ⚠️ Unexpected response (check logs): ${SIGNUP_TEST:0:200}"
fi
echo ""

# Step 5: Show next steps
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Backend deployment complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Apply Database Migration:"
echo "   Run: ./apply-migration-production.sh"
echo "   Or manually run: backend/migrations/007_add_trial_abuse_prevention.sql"
echo ""
echo "2. Configure App Store Connect:"
echo "   - Go to App Store Connect → Subscriptions"
echo "   - Add Introductory Offer (7-day free trial)"
echo "   - See: TRIAL_ABUSE_PREVENTION_COMPLETE.md"
echo ""
echo "3. Test in iOS App:"
echo "   - Build and run in Xcode"
echo "   - New signups should see paywall immediately"
echo "   - Subscribe button should show trial if eligible"
echo ""
echo "4. View Logs:"
echo "   az webapp log tail --name homework-helper-api --resource-group homework-helper-rg-f"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Clean up
rm -f backend-trial-prevention.zip
echo "🧹 Cleaned up deployment package"
echo ""
echo "🎉 Done!"

