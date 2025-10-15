#!/bin/bash

# ========================================
# Pre-Deployment Validation Script
# ========================================
# Run this BEFORE deploying to any environment
# Validates configuration and prevents breaking production

set -e

echo "╔═══════════════════════════════════════════════════╗"
echo "║   🔍 Pre-Deployment Health Check                 ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get target environment (default to staging)
ENVIRONMENT=${1:-staging}

echo "Target Environment: $ENVIRONMENT"
echo ""

# Set backend URL based on environment
if [ "$ENVIRONMENT" = "development" ]; then
    BACKEND_URL="http://localhost:3000"
elif [ "$ENVIRONMENT" = "staging" ]; then
    BACKEND_URL="https://homework-helper-staging.azurewebsites.net"
elif [ "$ENVIRONMENT" = "production" ]; then
    BACKEND_URL="https://homework-helper-api.azurewebsites.net"
else
    echo -e "${RED}❌ Invalid environment: $ENVIRONMENT${NC}"
    echo "Usage: ./pre-deploy-check.sh [development|staging|production]"
    exit 1
fi

echo "Backend URL: $BACKEND_URL"
echo ""
echo "Running checks..."
echo ""

# Test 1: Basic Health Check
echo "1️⃣  Testing basic health endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/api/health" || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "   ${GREEN}✅ Server is responding${NC}"
else
    echo -e "   ${RED}❌ Server not responding (HTTP $HTTP_CODE)${NC}"
    if [ "$ENVIRONMENT" = "development" ]; then
        echo -e "   ${YELLOW}⚠️  Make sure backend is running: npm run dev:watch${NC}"
    fi
    exit 1
fi

# Test 2: Detailed Health Check
echo ""
echo "2️⃣  Testing detailed health endpoint..."
HEALTH_RESPONSE=$(curl -s "$BACKEND_URL/api/health/detailed")

if [ -z "$HEALTH_RESPONSE" ]; then
    echo -e "   ${RED}❌ No response from detailed health check${NC}"
    exit 1
fi

# Parse JSON response
STATUS=$(echo "$HEALTH_RESPONSE" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
OPENAI_STATUS=$(echo "$HEALTH_RESPONSE" | grep -o '"openai":{[^}]*"status":"[^"]*"' | grep -o 'status":"[^"]*"' | cut -d'"' -f3)
OPENAI_SOURCE=$(echo "$HEALTH_RESPONSE" | grep -o '"source":"[^"]*"' | cut -d'"' -f4)
DB_STATUS=$(echo "$HEALTH_RESPONSE" | grep -o '"database":{[^}]*"status":"[^"]*"' | grep -o 'status":"[^"]*"' | cut -d'"' -f3)

echo "   Overall Status: $STATUS"
echo "   OpenAI: $OPENAI_STATUS (source: $OPENAI_SOURCE)"
echo "   Database: $DB_STATUS"

if [ "$STATUS" = "healthy" ]; then
    echo -e "   ${GREEN}✅ All services healthy${NC}"
else
    echo -e "   ${RED}❌ Some services unhealthy${NC}"
    echo ""
    echo "Full response:"
    echo "$HEALTH_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$HEALTH_RESPONSE"
    exit 1
fi

# Test 3: Verify OpenAI Key Configuration
echo ""
echo "3️⃣  Verifying OpenAI configuration..."

if [ "$ENVIRONMENT" = "production" ]; then
    if [ "$OPENAI_SOURCE" != "azure_key_vault" ]; then
        echo -e "   ${YELLOW}⚠️  WARNING: Production should use Azure Key Vault!${NC}"
        echo "   Current source: $OPENAI_SOURCE"
        read -p "   Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo -e "   ${GREEN}✅ Production using Azure Key Vault${NC}"
    fi
else
    if [ "$OPENAI_SOURCE" = "environment_variable" ]; then
        echo -e "   ${GREEN}✅ Dev/Staging using direct API key${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Using Key Vault in $ENVIRONMENT${NC}"
    fi
fi

# Test 4: Check environment matches
echo ""
echo "4️⃣  Verifying environment configuration..."
ENV_FROM_API=$(echo "$HEALTH_RESPONSE" | grep -o '"environment":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ "$ENV_FROM_API" = "$ENVIRONMENT" ]; then
    echo -e "   ${GREEN}✅ Environment matches: $ENV_FROM_API${NC}"
else
    echo -e "   ${RED}❌ Environment mismatch!${NC}"
    echo "   Expected: $ENVIRONMENT"
    echo "   Actual: $ENV_FROM_API"
    exit 1
fi

# Summary
echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║   ✅ All Pre-Deployment Checks Passed            ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
echo "Environment: $ENVIRONMENT"
echo "Backend: $BACKEND_URL"
echo "Status: Ready for deployment! 🚀"
echo ""

if [ "$ENVIRONMENT" = "production" ]; then
    echo -e "${YELLOW}⚠️  PRODUCTION DEPLOYMENT${NC}"
    echo "This will affect REAL USERS!"
    echo ""
    read -p "Are you sure you want to deploy to production? (yes/no): " -r
    echo
    if [[ ! $REPLY = "yes" ]]; then
        echo "Deployment cancelled."
        exit 1
    fi
fi

exit 0
