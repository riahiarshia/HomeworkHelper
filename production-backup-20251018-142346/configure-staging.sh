#!/bin/bash

# ========================================
# Configure Azure Staging Environment
# ========================================
# Sets environment variables in Azure (NOT from local .env files)

set -e

echo "╔═══════════════════════════════════════════════════╗"
echo "║   ⚙️  Configure Azure Staging Environment        ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
RESOURCE_GROUP="homework-helper-rg"
APP_NAME="homework-helper-staging"

echo "This script will configure environment variables for:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  App Service: $APP_NAME"
echo ""

# Prompt for OpenAI key
echo -e "${YELLOW}⚠️  IMPORTANT: Enter your STAGING/DEV OpenAI API key${NC}"
echo "   (NOT your local .env.development file - we'll set it directly in Azure)"
echo ""
read -p "OpenAI API Key (sk-proj-...): " OPENAI_KEY

if [[ ! $OPENAI_KEY =~ ^sk- ]]; then
    echo -e "${RED}❌ Invalid OpenAI key format${NC}"
    exit 1
fi

# Show first 10 characters for verification
KEY_PREVIEW="${OPENAI_KEY:0:10}..."
echo "Key preview: $KEY_PREVIEW"
echo ""

# Prompt for database URL
echo "Enter your Azure PostgreSQL connection string:"
echo "Format: postgresql://user:password@host:5432/database?ssl=true"
read -p "Database URL: " DATABASE_URL

echo ""
echo "Configuring Azure App Service environment variables..."
echo ""

# Set all environment variables in Azure
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    NODE_ENV=staging \
    PORT=8080 \
    APP_URL="https://$APP_NAME.azurewebsites.net" \
    OPENAI_API_KEY="$OPENAI_KEY" \
    DATABASE_URL="$DATABASE_URL" \
    JWT_SECRET="$(openssl rand -base64 32)" \
    ADMIN_JWT_SECRET="$(openssl rand -base64 32)" \
    STRIPE_SECRET_KEY="sk_test_YOUR_TEST_KEY" \
    ADMIN_USERNAME="admin" \
    ADMIN_PASSWORD="$(openssl rand -base64 16)" \
    DEBUG="true" \
    LOG_LEVEL="info"

echo ""
echo -e "${GREEN}✅ Azure staging environment configured!${NC}"
echo ""
echo "Configuration summary:"
echo "  Environment: staging"
echo "  OpenAI Key: $KEY_PREVIEW"
echo "  Database: Configured"
echo "  Secrets: Auto-generated"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT NOTES:${NC}"
echo "  1. The OpenAI key is stored ONLY in Azure (not in any local files)"
echo "  2. Your local .env.development file is NOT used by staging"
echo "  3. Staging and local dev are completely isolated"
echo ""
echo "Next steps:"
echo "  1. Deploy code: ./deploy-staging.sh"
echo "  2. Test: curl https://$APP_NAME.azurewebsites.net/api/health/detailed"
echo ""
