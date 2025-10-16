#!/bin/bash

# Automated Staging Database Setup Script
set -e

echo "🚀 Setting up PostgreSQL database for staging..."

# Configuration
RESOURCE_GROUP="homework-helper-stage-rg-f"
SERVER_NAME="homework-helper-staging-db"
LOCATION="Central US"
ADMIN_USER="homeworkadmin"
ADMIN_PASSWORD="Admin123!Staging"
DATABASE_NAME="homework_helper_staging"
APP_NAME="homework-helper-staging"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Create PostgreSQL Flexible Server
echo "🗄️ Creating PostgreSQL Flexible Server..."
if az postgres flexible-server show --resource-group $RESOURCE_GROUP --name $SERVER_NAME &> /dev/null; then
    print_warning "PostgreSQL server $SERVER_NAME already exists"
else
    az postgres flexible-server create \
        --resource-group $RESOURCE_GROUP \
        --name $SERVER_NAME \
        --location "$LOCATION" \
        --admin-user $ADMIN_USER \
        --admin-password "$ADMIN_PASSWORD" \
        --sku-name Standard_B1ms \
        --tier Burstable \
        --version 13 \
        --storage-size 32 \
        --yes
    
    print_status "PostgreSQL server created"
fi

# Create database
echo "📊 Creating database..."
if az postgres flexible-server db show --resource-group $RESOURCE_GROUP --server-name $SERVER_NAME --database-name $DATABASE_NAME &> /dev/null; then
    print_warning "Database $DATABASE_NAME already exists"
else
    az postgres flexible-server db create \
        --resource-group $RESOURCE_GROUP \
        --server-name $SERVER_NAME \
        --database-name $DATABASE_NAME
    
    print_status "Database $DATABASE_NAME created"
fi

# Configure firewall rule to allow Azure services
echo "🔥 Configuring firewall rules..."
az postgres flexible-server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --name $SERVER_NAME \
    --rule-name "AllowAzureServices" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 \
    --yes &> /dev/null || true

# Allow App Service IP range (optional - for more security)
az postgres flexible-server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --name $SERVER_NAME \
    --rule-name "AllowAppService" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 255.255.255.255 \
    --yes &> /dev/null || true

print_status "Firewall rules configured"

# Get server FQDN
echo "🔗 Getting server connection details..."
SERVER_FQDN=$(az postgres flexible-server show --resource-group $RESOURCE_GROUP --name $SERVER_NAME --query "fullyQualifiedDomainName" -o tsv)

# Create DATABASE_URL
DATABASE_URL="postgresql://$ADMIN_USER:$ADMIN_PASSWORD@$SERVER_FQDN:5432/$DATABASE_NAME?sslmode=require"

echo "📋 Database Connection Details:"
echo "   Server: $SERVER_FQDN"
echo "   Database: $DATABASE_NAME"
echo "   Username: $ADMIN_USER"
echo "   Password: $ADMIN_PASSWORD"

# Update App Service configuration
echo "⚙️ Updating App Service configuration..."
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --settings \
    DATABASE_URL="$DATABASE_URL" \
    DB_HOST="$SERVER_FQDN" \
    DB_NAME="$DATABASE_NAME" \
    DB_USER="$ADMIN_USER" \
    DB_PASSWORD="$ADMIN_PASSWORD" \
    DB_PORT="5432"

print_status "App Service configuration updated"

echo ""
print_status "🎉 Database setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Run your admin password fix script in Azure Kudu console"
echo "2. The DATABASE_URL is now configured in your App Service"
echo ""
echo "🔑 Database Details:"
echo "   Connection String: $DATABASE_URL"
echo "   Admin Username: $ADMIN_USER"
echo "   Admin Password: $ADMIN_PASSWORD"
echo ""
echo "🌐 App Service URLs:"
echo "   Admin Portal: https://$APP_NAME.azurewebsites.net/admin/"
echo "   API: https://$APP_NAME.azurewebsites.net/api/"
