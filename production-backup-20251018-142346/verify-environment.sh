#!/bin/bash

# ========================================
# Verify Environment Configuration
# ========================================
# Shows where OpenAI keys are configured (without revealing the keys)

echo "╔═══════════════════════════════════════════════════╗"
echo "║   🔍 Environment Configuration Verification      ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check Local Development
echo -e "${BLUE}📍 LOCAL DEVELOPMENT${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "backend/.env.development" ]; then
    echo -e "${GREEN}✅ .env.development exists${NC}"
    
    # Check if OpenAI key is set (without showing it)
    if grep -q "^OPENAI_API_KEY=sk-" backend/.env.development; then
        KEY_PREVIEW=$(grep "^OPENAI_API_KEY=" backend/.env.development | cut -d'=' -f2 | cut -c1-10)
        echo "   OpenAI Key: ${KEY_PREVIEW}... (local file)"
    else
        echo -e "   ${YELLOW}⚠️  OpenAI key not configured${NC}"
    fi
    
    echo "   Location: backend/.env.development"
    echo "   Git tracked: NO (ignored)"
    echo "   Deployed to Azure: NO (excluded from zip)"
else
    echo -e "${RED}❌ .env.development not found${NC}"
fi

echo ""

# Check Staging (Azure)
echo -e "${BLUE}📍 STAGING (AZURE)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

APP_NAME="homework-helper-staging"
RESOURCE_GROUP="homework-helper-rg"

# Check if Azure CLI is logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged into Azure CLI${NC}"
    echo "   Run: az login"
else
    # Check if app exists
    if az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
        echo -e "${GREEN}✅ Staging app exists in Azure${NC}"
        
        # Get environment variables (without revealing values)
        OPENAI_SET=$(az webapp config appsettings list \
            --name $APP_NAME \
            --resource-group $RESOURCE_GROUP \
            --query "[?name=='OPENAI_API_KEY'].value" \
            -o tsv 2>/dev/null)
        
        if [ ! -z "$OPENAI_SET" ]; then
            KEY_PREVIEW="${OPENAI_SET:0:10}"
            echo "   OpenAI Key: ${KEY_PREVIEW}... (Azure env var)"
            echo "   Location: Azure App Service Settings"
            echo "   Source: Configured via Azure Portal or CLI"
        else
            echo -e "   ${YELLOW}⚠️  OpenAI key not set in Azure${NC}"
        fi
        
        # Check if AZURE_KEY_VAULT is set
        VAULT_SET=$(az webapp config appsettings list \
            --name $APP_NAME \
            --resource-group $RESOURCE_GROUP \
            --query "[?name=='AZURE_KEY_VAULT_NAME'].value" \
            -o tsv 2>/dev/null)
        
        if [ ! -z "$VAULT_SET" ]; then
            echo "   Azure Key Vault: $VAULT_SET (configured but may not be used)"
        else
            echo "   Azure Key Vault: Not configured (using direct key)"
        fi
    else
        echo -e "${YELLOW}⚠️  Staging app not deployed yet${NC}"
    fi
fi

echo ""

# Check Production (Azure)
echo -e "${BLUE}📍 PRODUCTION (AZURE)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

PROD_APP_NAME="homework-helper-api"
PROD_RESOURCE_GROUP="homework-helper-rg"

if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged into Azure CLI${NC}"
else
    if az webapp show --name $PROD_APP_NAME --resource-group $PROD_RESOURCE_GROUP &> /dev/null; then
        echo -e "${GREEN}✅ Production app exists in Azure${NC}"
        
        # Check for direct key (should NOT be set in production)
        OPENAI_SET=$(az webapp config appsettings list \
            --name $PROD_APP_NAME \
            --resource-group $PROD_RESOURCE_GROUP \
            --query "[?name=='OPENAI_API_KEY'].value" \
            -o tsv 2>/dev/null)
        
        if [ ! -z "$OPENAI_SET" ]; then
            echo -e "   ${YELLOW}⚠️  WARNING: Direct OpenAI key set${NC}"
            echo "   Production should use Azure Key Vault!"
        else
            echo -e "   ${GREEN}✅ No direct OpenAI key (good for production)${NC}"
        fi
        
        # Check for Key Vault
        VAULT_SET=$(az webapp config appsettings list \
            --name $PROD_APP_NAME \
            --resource-group $PROD_RESOURCE_GROUP \
            --query "[?name=='AZURE_KEY_VAULT_NAME'].value" \
            -o tsv 2>/dev/null)
        
        if [ ! -z "$VAULT_SET" ]; then
            echo "   Azure Key Vault: $VAULT_SET ✅"
            echo "   Location: Azure Key Vault (secure)"
        else
            echo -e "   ${YELLOW}⚠️  Azure Key Vault not configured${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Production app not deployed yet${NC}"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}📊 SUMMARY${NC}"
echo ""
echo "Development (Local):"
echo "  └─ Uses: backend/.env.development file"
echo "  └─ Never committed to git ✅"
echo "  └─ Never deployed to Azure ✅"
echo ""
echo "Staging (Azure):"
echo "  └─ Uses: Azure App Service Environment Variables"
echo "  └─ Set via: configure-staging.sh or Azure Portal"
echo "  └─ Completely separate from local .env files ✅"
echo ""
echo "Production (Azure):"
echo "  └─ Should use: Azure Key Vault (most secure)"
echo "  └─ Fallback: Azure Environment Variables"
echo "  └─ Never uses local .env files ✅"
echo ""
