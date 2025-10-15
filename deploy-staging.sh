#!/bin/bash

# ========================================
# Deploy to Azure Staging Environment
# ========================================

set -e

echo "🚀 Deploying Homework Helper Backend to Staging..."
echo ""

# Pre-deployment validation
echo "Running pre-deployment checks..."
./pre-deploy-check.sh staging

if [ $? -ne 0 ]; then
    echo "❌ Pre-deployment checks failed! Aborting deployment."
    exit 1
fi

echo ""

# Configuration
RESOURCE_GROUP="homework-helper-rg"
APP_NAME="homework-helper-staging"

# Navigate to backend
cd backend

# Install production dependencies only
echo "📦 Installing dependencies..."
npm ci --production

# Create deployment package (exclude dev files)
echo "📦 Creating deployment package..."
zip -r ../staging-deploy.zip . \
  -x "node_modules/*" \
  -x ".git/*" \
  -x ".env*" \
  -x "*.log" \
  -x "*.zip" \
  -x "tests/*" \
  -x "*.md"

cd ..

# Deploy to Azure
echo "☁️ Deploying to Azure App Service: $APP_NAME..."
az webapp deployment source config-zip \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --src staging-deploy.zip

# Clean up
rm staging-deploy.zip

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🔗 Your staging backend is at:"
echo "   https://$APP_NAME.azurewebsites.net"
echo ""
echo "🧪 Test it:"
echo "   curl https://$APP_NAME.azurewebsites.net/health"
echo ""
