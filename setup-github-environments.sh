#!/bin/bash

# GitHub Environments Setup Script
# This script helps set up Azure service principals for GitHub Environments

set -e

echo "🚀 GitHub Environments Setup Script"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    print_error "You are not logged in to Azure CLI."
    echo "Please run: az login"
    exit 1
fi

print_status "Azure CLI is installed and you are logged in"

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
print_info "Current subscription: $SUBSCRIPTION_ID"

echo ""
echo "🔧 Setting up Azure Service Principals for GitHub Environments"
echo "=============================================================="
echo ""

# Create staging service principal
print_info "Creating staging service principal..."
STAGING_SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "homework-helper-staging-github" \
    --role contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/homework-helper-stage-rg-f" \
    --sdk-auth)

if [ $? -eq 0 ]; then
    print_status "Staging service principal created successfully"
    echo ""
    print_info "STAGING AZURE_CREDENTIALS (add this to GitHub Secrets):"
    echo "=================================================="
    echo "$STAGING_SP_OUTPUT"
    echo "=================================================="
    echo ""
else
    print_error "Failed to create staging service principal"
    exit 1
fi

# Create production service principal
print_info "Creating production service principal..."
PROD_SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "homework-helper-prod-github" \
    --role contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/homework-helper-rg-f" \
    --sdk-auth)

if [ $? -eq 0 ]; then
    print_status "Production service principal created successfully"
    echo ""
    print_info "PRODUCTION AZURE_CREDENTIALS (add this to GitHub Secrets):"
    echo "======================================================"
    echo "$PROD_SP_OUTPUT"
    echo "======================================================"
    echo ""
else
    print_error "Failed to create production service principal"
    exit 1
fi

# Get publish profiles
print_info "Getting publish profiles..."

# Staging publish profile
print_info "Getting staging publish profile..."
STAGING_PUBLISH_PROFILE=$(az webapp deployment list-publishing-profiles \
    --resource-group homework-helper-stage-rg-f \
    --name homework-helper-staging \
    --xml 2>/dev/null || echo "Staging app not found - you may need to create it first")

if [[ "$STAGING_PUBLISH_PROFILE" == *"Staging app not found"* ]]; then
    print_warning "Staging app not found. You may need to create it first."
    print_info "Run: ./deploy-staging.sh to create the staging environment"
else
    print_status "Staging publish profile retrieved"
    echo ""
    print_info "STAGING PUBLISH PROFILE (add this to GitHub Secrets):"
    echo "=================================================="
    echo "$STAGING_PUBLISH_PROFILE"
    echo "=================================================="
    echo ""
fi

# Production publish profile
print_info "Getting production publish profile..."
PROD_PUBLISH_PROFILE=$(az webapp deployment list-publishing-profiles \
    --resource-group homework-helper-rg-f \
    --name homework-helper-api \
    --xml 2>/dev/null || echo "Production app not found - you may need to create it first")

if [[ "$PROD_PUBLISH_PROFILE" == *"Production app not found"* ]]; then
    print_warning "Production app not found. You may need to create it first."
    print_info "Run: ./deploy-production.sh to create the production environment"
else
    print_status "Production publish profile retrieved"
    echo ""
    print_info "PRODUCTION PUBLISH PROFILE (add this to GitHub Secrets):"
    echo "======================================================"
    echo "$PROD_PUBLISH_PROFILE"
    echo "======================================================"
    echo ""
fi

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo ""
print_info "1. Go to your GitHub repository"
print_info "2. Navigate to Settings → Environments"
print_info "3. Create two environments: 'production' and 'staging'"
print_info "4. Add the secrets above to their respective environments"
print_info "5. Configure protection rules for production environment"
echo ""
print_info "📖 See GITHUB_ENVIRONMENTS_SETUP.md for detailed instructions"
echo ""
print_status "Setup script completed successfully!"
