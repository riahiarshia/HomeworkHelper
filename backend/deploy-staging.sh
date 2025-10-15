#!/bin/bash

# Azure Staging Deployment Script
# This script automates the deployment of the backend to Azure App Service

set -e  # Exit on any error

echo "🚀 Starting Azure Staging Deployment..."

# Configuration
RESOURCE_GROUP="homework-helper-stage-rg-f"
APP_NAME="homework-helper-staging"
APP_PLAN="homework-helper-stage-plan"
LOCATION="Central US"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Azure CLI is logged in
echo "🔍 Checking Azure CLI authentication..."
if ! az account show &> /dev/null; then
    print_error "Not logged into Azure CLI. Please run 'az login' first."
    exit 1
fi
print_status "Azure CLI authenticated"

# Check if resource group exists
echo "🔍 Checking resource group..."
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    print_warning "Resource group $RESOURCE_GROUP not found. Creating..."
    az group create --name $RESOURCE_GROUP --location "$LOCATION"
    print_status "Resource group created"
else
    print_status "Resource group exists"
fi

# Check if App Service Plan exists
echo "🔍 Checking App Service Plan..."
if ! az appservice plan show --name $APP_PLAN --resource-group $RESOURCE_GROUP &> /dev/null; then
    print_warning "App Service Plan $APP_PLAN not found. Creating..."
    az appservice plan create --name $APP_PLAN --resource-group $RESOURCE_GROUP --location "$LOCATION" --sku B1 --is-linux
    print_status "App Service Plan created"
else
    print_status "App Service Plan exists"
fi

# Check if App Service exists
echo "🔍 Checking App Service..."
if ! az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
    print_warning "App Service $APP_NAME not found. Creating..."
    az webapp create --resource-group $RESOURCE_GROUP --plan $APP_PLAN --name $APP_NAME --runtime "NODE:18-lts"
    print_status "App Service created"
else
    print_status "App Service exists"
fi

# Configure environment variables
echo "⚙️  Configuring environment variables..."
az webapp config appsettings set --resource-group $RESOURCE_GROUP --name $APP_NAME --settings \
    NODE_ENV=staging \
    PORT=8080 \
    DEBUG=true \
    LOG_LEVEL=info \
    JWT_SECRET=staging-super-secret-jwt-key-minimum-32-characters-long \
    ADMIN_JWT_SECRET=staging-super-secret-admin-jwt-key-minimum-32-characters-long \
    APP_URL=https://$APP_NAME.azurewebsites.net \
    ADMIN_USERNAME=admin \
    ADMIN_PASSWORD=Admin123!Staging \
    ADMIN_EMAIL=admin@homeworkhelper-staging.com \
    LEDGER_SALT=staging-ledger-salt-378c8e9e7bdf5ed763a0e85056b97082

print_status "Environment variables configured"

# Create a proper deployment package (without node_modules)
echo "📦 Creating deployment package..."
cd "$(dirname "$0")"

# Remove old zip files
rm -f ../backend-staging-deploy.zip

# Create zip without node_modules (Azure will install them)
zip -r ../backend-staging-deploy.zip . \
    -x "node_modules/*" \
    ".git/*" \
    "*.log" \
    ".env*" \
    "deploy-staging.sh" \
    "*.zip"

print_status "Deployment package created"

# Deploy to Azure
echo "🚀 Deploying to Azure App Service..."
az webapp deploy --resource-group $RESOURCE_GROUP --name $APP_NAME --src-path ../backend-staging-deploy.zip --type zip

print_status "Deployment completed"

# Wait for deployment to complete
echo "⏳ Waiting for deployment to stabilize..."
sleep 30

# Test the deployment
echo "🧪 Testing deployment..."
if curl -f -s "https://$APP_NAME.azurewebsites.net/api/health" > /dev/null; then
    print_status "Deployment successful! App is responding."
    echo ""
    echo "🎉 Staging Environment URLs:"
    echo "   Backend API: https://$APP_NAME.azurewebsites.net"
    echo "   Admin Dashboard: https://$APP_NAME.azurewebsites.net/admin"
    echo "   Health Check: https://$APP_NAME.azurewebsites.net/api/health"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Create PostgreSQL database manually in Azure Portal"
    echo "   2. Update DATABASE_URL environment variable"
    echo "   3. Configure OpenAI API key"
    echo "   4. Configure Stripe keys"
else
    print_warning "Deployment completed but app may not be responding yet."
    echo "   Check logs: az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME"
fi

print_status "Deployment script completed!"
