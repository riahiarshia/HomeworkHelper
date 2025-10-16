#!/bin/bash

# Deploy Admin Fix Script to Staging
# This script will deploy the admin fix and run it

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
APP_NAME="homework-helper-staging"
RESOURCE_GROUP="homework-helper-stage-rg-f"
SCRIPT_NAME="fix-staging-admin.js"

print_status "🚀 Deploying Admin Fix Script to Staging"
print_status "App Name: $APP_NAME"
print_status "Resource Group: $RESOURCE_GROUP"

# Check if Azure CLI is logged in
if ! az account show &> /dev/null; then
    print_error "Not logged into Azure CLI. Please run 'az login' first."
    exit 1
fi

print_status "✅ Azure CLI authenticated"

# Deploy the script to Azure
print_status "📤 Uploading admin fix script to Azure..."

# Use Azure CLI to deploy the script
az webapp deployment source config-zip \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --src <(zip -r - fix-staging-admin.js) \
    --output none

if [ $? -eq 0 ]; then
    print_success "✅ Script uploaded successfully"
else
    print_error "❌ Failed to upload script"
    exit 1
fi

# Run the script remotely
print_status "🔧 Running admin fix script..."

# Execute the script using Azure CLI
az webapp ssh \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --command "cd /home/site/wwwroot && node fix-staging-admin.js"

if [ $? -eq 0 ]; then
    print_success "✅ Admin credentials updated successfully!"
    print_success ""
    print_success "🔑 New Admin Credentials:"
    print_success "   URL: https://$APP_NAME.azurewebsites.net/admin/"
    print_success "   Username: admin"
    print_success "   Password: Admin123!Staging"
    print_success ""
    print_success "✅ You can now login to the admin portal!"
else
    print_error "❌ Failed to run admin fix script"
    print_warning "You may need to run the script manually via Kudu console"
    print_warning "Go to: https://$APP_NAME.scm.azurewebsites.net"
    print_warning "Then run: node fix-staging-admin.js"
fi

print_status "🎉 Deployment complete!"
