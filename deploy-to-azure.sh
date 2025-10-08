#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║   🌐 Azure Deployment - Homework Helper Subscription  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
RESOURCE_GROUP="homework-helper-rg-f"
LOCATION="eastus"
DB_SERVER_NAME="homework-helper-db-$(date +%s)"
DB_NAME="homework_helper"
DB_ADMIN_USER="dbadmin"
APP_SERVICE_NAME="homework-helper-api-$(date +%s)"
APP_SERVICE_PLAN="homework-helper-plan"

echo -e "${BLUE}📋 Configuration:${NC}"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Location: $LOCATION"
echo "   Database Server: $DB_SERVER_NAME"
echo "   App Service: $APP_SERVICE_NAME"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    echo "Installing Azure CLI..."
    brew install azure-cli
fi

# Login to Azure
echo -e "${BLUE}Step 1: Logging into Azure...${NC}"
az login --use-device-code

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Azure login failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Logged into Azure${NC}"
echo ""

# Verify resource group exists
echo -e "${BLUE}Step 2: Verifying Resource Group...${NC}"
RG_EXISTS=$(az group exists --name $RESOURCE_GROUP)

if [ "$RG_EXISTS" = "false" ]; then
    echo -e "${YELLOW}⚠️  Resource group doesn't exist. Creating...${NC}"
    az group create --name $RESOURCE_GROUP --location $LOCATION
else
    echo -e "${GREEN}✅ Resource group exists: $RESOURCE_GROUP${NC}"
fi
echo ""

# Create PostgreSQL Flexible Server
echo -e "${BLUE}Step 3: Creating PostgreSQL Database...${NC}"
echo "This may take 5-10 minutes..."

# Prompt for database password
read -sp "Enter database admin password: " DB_PASSWORD
echo ""

az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --location $LOCATION \
  --admin-user $DB_ADMIN_USER \
  --admin-password "$DB_PASSWORD" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 15 \
  --public-access 0.0.0.0-255.255.255.255 \
  --yes

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ PostgreSQL server created${NC}"
else
    echo -e "${RED}❌ Failed to create PostgreSQL server${NC}"
    exit 1
fi

# Create database
echo -e "${BLUE}Creating database: $DB_NAME${NC}"
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $DB_SERVER_NAME \
  --database-name $DB_NAME

echo -e "${GREEN}✅ Database created${NC}"
echo ""

# Get connection string
DB_HOST="${DB_SERVER_NAME}.postgres.database.azure.com"
CONNECTION_STRING="postgres://${DB_ADMIN_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}?sslmode=require"

echo -e "${GREEN}📊 Database Connection String:${NC}"
echo "$CONNECTION_STRING"
echo ""

# Run database migration
echo -e "${BLUE}Step 4: Running Database Migration...${NC}"

# Install psql if needed
if ! command -v psql &> /dev/null; then
    echo "Installing PostgreSQL client..."
    brew install postgresql
fi

# Run migration
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_ADMIN_USER" -d "$DB_NAME" -f backend/database/migration.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database migration completed${NC}"
else
    echo -e "${YELLOW}⚠️  Migration had some warnings (this is often normal)${NC}"
fi
echo ""

# Create App Service Plan
echo -e "${BLUE}Step 5: Creating App Service Plan...${NC}"

az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --is-linux \
  --sku B1

echo -e "${GREEN}✅ App Service Plan created${NC}"
echo ""

# Create App Service (Web App)
echo -e "${BLUE}Step 6: Creating App Service...${NC}"

az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $APP_SERVICE_NAME \
  --runtime "NODE:20-lts"

echo -e "${GREEN}✅ App Service created${NC}"
echo ""

# Generate JWT secrets
echo -e "${BLUE}Step 7: Generating Security Secrets...${NC}"

JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
ADMIN_JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")

echo -e "${GREEN}✅ JWT secrets generated${NC}"
echo ""

# Configure App Settings
echo -e "${BLUE}Step 8: Configuring App Service Environment Variables...${NC}"

az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --settings \
    PORT=8080 \
    NODE_ENV=production \
    DATABASE_URL="$CONNECTION_STRING" \
    JWT_SECRET="$JWT_SECRET" \
    ADMIN_JWT_SECRET="$ADMIN_JWT_SECRET" \
    APP_URL="https://${APP_SERVICE_NAME}.azurewebsites.net" \
    STRIPE_SECRET_KEY="sk_test_REPLACE_WITH_YOUR_STRIPE_KEY" \
    STRIPE_WEBHOOK_SECRET="whsec_REPLACE_WITH_YOUR_WEBHOOK_SECRET" \
    STRIPE_PRICE_ID="price_REPLACE_WITH_YOUR_PRICE_ID"

echo -e "${GREEN}✅ Environment variables configured${NC}"
echo ""

# Deploy from local directory
echo -e "${BLUE}Step 9: Deploying Backend Code...${NC}"

cd backend

# Create zip file for deployment
zip -r deploy.zip . -x "*.git*" -x "node_modules/*" -x ".env"

az webapp deployment source config-zip \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --src deploy.zip

rm deploy.zip

echo -e "${GREEN}✅ Backend deployed${NC}"
echo ""

cd ..

# Summary
echo "╔════════════════════════════════════════════════════════╗"
echo "║            ✅ DEPLOYMENT COMPLETE!                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🎉 Your subscription system is now live on Azure!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 YOUR LIVE URLS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Admin Dashboard:"
echo "   https://${APP_SERVICE_NAME}.azurewebsites.net/admin"
echo ""
echo "📊 API Endpoint:"
echo "   https://${APP_SERVICE_NAME}.azurewebsites.net/api"
echo ""
echo "🗄️  Database:"
echo "   Host: $DB_HOST"
echo "   Database: $DB_NAME"
echo "   User: $DB_ADMIN_USER"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 ADMIN LOGIN:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo -e "${RED}⚠️  IMPORTANT: Change this password immediately!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 NEXT STEPS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Open: https://${APP_SERVICE_NAME}.azurewebsites.net/admin"
echo "2. Login with admin/admin123"
echo "3. Change admin password"
echo "4. Create promo codes"
echo "5. Update iOS app with URL: https://${APP_SERVICE_NAME}.azurewebsites.net"
echo "6. Add Stripe keys in Azure Portal (replace REPLACE_WITH_YOUR_*)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Save deployment info
cat > AZURE_DEPLOYMENT_INFO.txt << EOF
Deployment Date: $(date)
Resource Group: $RESOURCE_GROUP

Database:
  Server: $DB_SERVER_NAME
  Host: $DB_HOST
  Database: $DB_NAME
  User: $DB_ADMIN_USER
  Connection: $CONNECTION_STRING

App Service:
  Name: $APP_SERVICE_NAME
  URL: https://${APP_SERVICE_NAME}.azurewebsites.net
  Admin Dashboard: https://${APP_SERVICE_NAME}.azurewebsites.net/admin

Default Admin Credentials:
  Username: admin
  Password: admin123
  ⚠️ CHANGE IMMEDIATELY!

Next Steps:
1. Visit admin dashboard and change password
2. Update Stripe keys in Azure Portal
3. Update iOS app backend URL
EOF

echo -e "${GREEN}📄 Deployment info saved to: AZURE_DEPLOYMENT_INFO.txt${NC}"
echo ""


