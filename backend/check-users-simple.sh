#!/bin/bash

# Check users in staging vs production databases

echo "🔍 Checking users in staging vs production..."

# Get connection strings from Azure
echo "📡 Getting connection strings from Azure..."

PROD_CONNECTION_STRING=$(az webapp config appsettings list \
    --resource-group homework-helper-rg-f \
    --name homework-helper-api \
    --query "[?name=='DATABASE_URL'].value" \
    --output tsv)

STAGING_CONNECTION_STRING=$(az webapp config appsettings list \
    --resource-group homework-helper-stage-rg-f \
    --name homework-helper-staging \
    --query "[?name=='DATABASE_URL'].value" \
    --output tsv)

echo "✅ Got connection strings"

echo ""
echo "📊 STAGING USERS (last 10):"
psql "$STAGING_CONNECTION_STRING" -c "
SELECT email, username, auth_provider, created_at, is_active 
FROM users 
ORDER BY created_at DESC 
LIMIT 10;
"

echo ""
echo "📊 PRODUCTION USERS (last 10):"
psql "$PROD_CONNECTION_STRING" -c "
SELECT email, username, auth_provider, created_at, is_active 
FROM users 
ORDER BY created_at DESC 
LIMIT 10;
"

echo ""
echo "🔍 Checking for riahiarshia@gmail.com specifically:"
echo ""
echo "📊 In STAGING:"
psql "$STAGING_CONNECTION_STRING" -c "
SELECT * FROM users WHERE email = 'riahiarshia@gmail.com';
"

echo ""
echo "📊 In PRODUCTION:"
psql "$PROD_CONNECTION_STRING" -c "
SELECT * FROM users WHERE email = 'riahiarshia@gmail.com';
"

echo ""
echo "📈 Total user counts:"
echo "Staging:"
psql "$STAGING_CONNECTION_STRING" -c "SELECT COUNT(*) as staging_count FROM users;"

echo "Production:"
psql "$PROD_CONNECTION_STRING" -c "SELECT COUNT(*) as production_count FROM users;"
