#!/bin/bash

# Clean Production Environment Setup Script
# This script sets up production environment without exposing secrets

set -e

echo "🚀 CLEAN PRODUCTION ENVIRONMENT SETUP"
echo "====================================="
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   brew install gh"
    echo "   or visit: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub. Please run:"
    echo "   gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready"
echo ""

echo "🔍 STEP 1: Checking current environment status..."
echo "-----------------------------------------------"

# Check current environments
echo "📋 Current GitHub Environments:"
gh api repos/:owner/:repo/environments --jq '.[].name' 2>/dev/null || echo "No environments found"

echo ""
echo "🔍 STEP 2: Production environment setup..."
echo "------------------------------------------"

# Check if production environment exists
if gh api repos/:owner/:repo/environments/production &> /dev/null; then
    echo "✅ Production environment exists"
    
    # List production secrets
    echo "📋 Production environment secrets:"
    gh secret list --env production 2>/dev/null || echo "No secrets found in production"
else
    echo "❌ Production environment does not exist"
    echo ""
    echo "📋 MANUAL STEP REQUIRED:"
    echo "1. Go to: https://github.com/riahiarshia/HomeworkHelper/settings/environments"
    echo "2. Click 'New environment'"
    echo "3. Name: production"
    echo "4. Description: Production environment for live application"
    echo "5. Click 'Configure environment'"
    echo ""
    echo "⏳ Waiting for you to create the production environment..."
    echo "Press Enter when you've created the production environment..."
    read -r
fi

echo ""
echo "🔍 STEP 3: Production environment summary..."
echo "-------------------------------------------"

echo "📊 Production Environment Status:"
if gh api repos/:owner/:repo/environments/production &> /dev/null; then
    echo "   ✅ Environment exists"
    echo "   ✅ Ready for deployment"
    echo "   🌐 URL: https://homework-helper-api.azurewebsites.net"
    
    # List production secrets
    echo "   📋 Production secrets:"
    gh secret list --env production 2>/dev/null | sed 's/^/      /' || echo "      No secrets found"
else
    echo "   ❌ Environment not found"
fi

echo ""
echo "🎉 PRODUCTION SETUP COMPLETE!"
echo "============================="
echo ""
echo "📋 Next steps:"
echo "   1. Add Azure credentials to production environment secrets"
echo "   2. Add Azure publish profile to production environment secrets"
echo "   3. Set up protection rules (manual approval required)"
echo "   4. Push to main branch to trigger production deployment"
echo ""
echo "✅ Setup completed successfully!"
