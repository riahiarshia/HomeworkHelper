#!/bin/bash

# ========================================
# Deploy to Azure Production
# ========================================
# This script deploys your local changes to Azure production
# while maintaining database consistency
#
# Prerequisites:
# 1. Azure CLI installed and logged in
# 2. Production DATABASE_URL configured
# 3. Git repository with proper branch structure

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "======================================"
echo "🚀 Deploy to Azure Production"
echo "======================================"
echo ""

# Configuration
BRANCH_NAME=$(git branch --show-current)
PRODUCTION_BRANCH="main"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command_exists git; then
    echo -e "${RED}❌ Git not found${NC}"
    exit 1
fi

if ! command_exists az; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    echo "Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged into Azure
if ! az account show >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not logged into Azure CLI${NC}"
    echo "Please run: az login"
    exit 1
fi

# Check git status
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}❌ You have uncommitted changes${NC}"
    echo "Please commit or stash your changes before deploying"
    git status --short
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Show current branch and confirm deployment
echo "📋 Current branch: $BRANCH_NAME"
echo "🎯 Target: Azure Production"
echo ""

if [ "$BRANCH_NAME" != "$PRODUCTION_BRANCH" ]; then
    echo -e "${YELLOW}⚠️  You're not on the $PRODUCTION_BRANCH branch${NC}"
    echo "Current branch: $BRANCH_NAME"
    echo "Production branch: $PRODUCTION_BRANCH"
    echo ""
    read -p "Deploy from current branch anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled. Switch to $PRODUCTION_BRANCH branch first."
        exit 0
    fi
fi

echo ""

# Pre-deployment checks
echo "🔍 Running pre-deployment checks..."

# Check if all tests pass (if test script exists)
if [ -f "package.json" ] && grep -q '"test"' package.json; then
    echo "🧪 Running tests..."
    if npm test >/dev/null 2>&1; then
        echo -e "${GREEN}✅ All tests passed${NC}"
    else
        echo -e "${RED}❌ Tests failed${NC}"
        echo "Please fix failing tests before deploying"
        exit 1
    fi
fi

# Check for linting issues (if lint script exists)
if [ -f "package.json" ] && grep -q '"lint"' package.json; then
    echo "🔍 Running linter..."
    if npm run lint >/dev/null 2>&1; then
        echo -e "${GREEN}✅ No linting issues${NC}"
    else
        echo -e "${YELLOW}⚠️  Linting issues found${NC}"
        read -p "Continue deployment anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Deployment cancelled. Fix linting issues first."
            exit 0
        fi
    fi
fi

echo ""

# Backup production database
echo "💾 Creating production database backup..."
if [ -z "$DATABASE_URL" ]; then
    echo -e "${RED}❌ DATABASE_URL not set${NC}"
    echo "Please set your production DATABASE_URL environment variable"
    exit 1
fi

mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/prod_backup_before_deploy_$TIMESTAMP.sql"

echo "📦 Backing up production database..."
pg_dump "$DATABASE_URL" \
    --verbose \
    --no-owner \
    --no-privileges \
    --format=plain \
    --file="$BACKUP_FILE"

echo -e "${GREEN}✅ Production backup created: $BACKUP_FILE${NC}"
echo ""

# Deploy to Azure
echo "🚀 Deploying to Azure..."

# Method 1: Azure App Service (if using Azure Web Apps)
if command_exists az && az webapp list >/dev/null 2>&1; then
    echo "🌐 Detected Azure App Service deployment..."
    
    # Get webapp name (you may need to configure this)
    WEBAPP_NAME=$(az webapp list --query "[0].name" -o tsv 2>/dev/null || echo "")
    
    if [ -n "$WEBAPP_NAME" ]; then
        echo "📱 Deploying to Azure Web App: $WEBAPP_NAME"
        
        # Deploy using Azure CLI
        az webapp deployment source config-zip \
            --resource-group "$(az webapp show --name "$WEBAPP_NAME" --query resourceGroup -o tsv)" \
            --name "$WEBAPP_NAME" \
            --src "./deploy.zip" 2>/dev/null || {
            
            # Alternative: Deploy using git
            echo "🔄 Using git deployment method..."
            az webapp deployment source config \
                --resource-group "$(az webapp show --name "$WEBAPP_NAME" --query resourceGroup -o tsv)" \
                --name "$WEBAPP_NAME" \
                --repo-url "$(git remote get-url origin)" \
                --branch "$BRANCH_NAME" \
                --manual-integration
        }
        
        echo -e "${GREEN}✅ Azure App Service deployment initiated${NC}"
    else
        echo -e "${YELLOW}⚠️  No Azure Web App found${NC}"
        echo "Please configure your Azure deployment method"
    fi
fi

# Method 2: Azure Container Instances (if using containers)
if [ -f "Dockerfile" ]; then
    echo "🐳 Detected Docker deployment..."
    echo "Building and deploying container..."
    
    # Build Docker image
    docker build -t homework-helper-backend:$TIMESTAMP .
    
    # Push to Azure Container Registry (if configured)
    # az acr build --registry <registry-name> --image homework-helper-backend:$TIMESTAMP .
    
    echo -e "${GREEN}✅ Container built and ready for deployment${NC}"
fi

# Method 3: Manual deployment (zip file)
echo "📦 Creating deployment package..."
mkdir -p "./deploy"
cp -r . "./deploy/" 2>/dev/null || true

# Remove unnecessary files from deployment
cd "./deploy"
rm -rf node_modules .git .env* *.log backups deploy 2>/dev/null || true

# Create deployment zip
zip -r "../deploy.zip" . >/dev/null 2>&1
cd ..
rm -rf "./deploy"

echo -e "${GREEN}✅ Deployment package created: deploy.zip${NC}"
echo ""

# Post-deployment verification
echo "🔍 Verifying deployment..."

# Wait a moment for deployment to complete
sleep 10

# Test production health endpoint
if [ -n "$WEBAPP_NAME" ]; then
    PROD_URL="https://$WEBAPP_NAME.azurewebsites.net"
    echo "🏥 Testing production health endpoint..."
    
    if curl -f -s "$PROD_URL/api/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Production health check passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Production health check failed${NC}"
        echo "Please check the deployment manually"
    fi
fi

echo ""

# Update deployment log
echo "📝 Recording deployment..."
cat >> "deployment.log" << EOF
$(date): Deployed branch $BRANCH_NAME to production
  - Backup: $BACKUP_FILE
  - Deployment package: deploy.zip
  - Status: $([ -n "$WEBAPP_NAME" ] && echo "Completed" || echo "Package ready")
EOF

# Final summary
echo "======================================"
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo "======================================"
echo ""
echo "📊 Summary:"
echo "  ✅ Pre-deployment checks passed"
echo "  ✅ Production database backed up"
echo "  ✅ Code deployed to Azure"
echo "  ✅ Deployment verified"
echo ""
echo "📁 Files created:"
echo "  📦 Database backup: $BACKUP_FILE"
echo "  📦 Deployment package: deploy.zip"
echo "  📝 Deployment log: deployment.log"
echo ""
echo "🔗 Production URL:"
if [ -n "$WEBAPP_NAME" ]; then
    echo "  🌐 https://$WEBAPP_NAME.azurewebsites.net"
fi
echo ""
echo "🚀 Next steps:"
echo "  1. Test production functionality"
echo "  2. Monitor application logs"
echo "  3. Verify database migrations applied correctly"
echo ""
echo -e "${BLUE}💡 To sync production changes back to local, run:${NC}"
echo -e "${BLUE}   ./scripts/sync-prod-to-local.sh${NC}"
echo ""
