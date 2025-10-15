#!/bin/bash

# ==============================================
# Token Usage Tracking Deployment Script
# ==============================================
# This script sets up the usage tracking system
# for the Homework Helper backend
# ==============================================

set -e  # Exit on error

echo "🚀 Starting Token Usage Tracking Deployment..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check if DATABASE_URL is set
echo -e "${BLUE}📋 Step 1: Checking environment variables...${NC}"
if [ -z "$DATABASE_URL" ]; then
    echo -e "${YELLOW}⚠️  DATABASE_URL not set. Please set it:${NC}"
    echo "export DATABASE_URL='your_database_connection_string'"
    echo ""
    echo "Or run with:"
    echo "DATABASE_URL='your_connection_string' ./deploy-usage-tracking.sh"
    exit 1
fi
echo -e "${GREEN}✅ DATABASE_URL is set${NC}"
echo ""

# Step 2: Install npm dependencies
echo -e "${BLUE}📦 Step 2: Installing dependencies...${NC}"
if [ ! -d "node_modules" ]; then
    echo "node_modules not found. Running npm install..."
    npm install
else
    echo "Installing new packages (axios, json2csv)..."
    npm install axios json2csv --save
fi
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 3: Run database migration
echo -e "${BLUE}🗄️  Step 3: Running database migration...${NC}"
if [ ! -f "database/usage-tracking-migration.sql" ]; then
    echo -e "${RED}❌ Migration file not found: database/usage-tracking-migration.sql${NC}"
    exit 1
fi

echo "Running migration..."
psql "$DATABASE_URL" -f database/usage-tracking-migration.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database migration completed successfully${NC}"
else
    echo -e "${RED}❌ Database migration failed${NC}"
    exit 1
fi
echo ""

# Step 4: Verify database setup
echo -e "${BLUE}🔍 Step 4: Verifying database setup...${NC}"
echo "Checking if user_api_usage table exists..."
TABLE_EXISTS=$(psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_api_usage');")

if [[ $TABLE_EXISTS == *"t"* ]]; then
    echo -e "${GREEN}✅ user_api_usage table exists${NC}"
    
    # Check views
    echo "Checking views..."
    VIEWS=$(psql "$DATABASE_URL" -t -c "SELECT count(*) FROM information_schema.views WHERE table_name IN ('user_usage_summary', 'monthly_usage_summary', 'endpoint_usage_summary', 'daily_usage_summary');")
    VIEWS=$(echo $VIEWS | tr -d ' ')
    
    if [ "$VIEWS" == "4" ]; then
        echo -e "${GREEN}✅ All 4 views created successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Expected 4 views, found $VIEWS${NC}"
    fi
else
    echo -e "${RED}❌ user_api_usage table not found${NC}"
    exit 1
fi
echo ""

# Step 5: Test API endpoints
echo -e "${BLUE}🧪 Step 5: Testing backend server...${NC}"
if pgrep -f "node.*server.js" > /dev/null; then
    echo -e "${GREEN}✅ Backend server is running${NC}"
else
    echo -e "${YELLOW}⚠️  Backend server is not running${NC}"
    echo "Start it with: npm start"
fi
echo ""

# Step 6: Display summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 Token Usage Tracking Deployment Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 What was deployed:"
echo "  ✅ Database table: user_api_usage"
echo "  ✅ Views: user_usage_summary, monthly_usage_summary, endpoint_usage_summary, daily_usage_summary"
echo "  ✅ API routes: /api/usage/*"
echo "  ✅ Admin portal: API Usage tab"
echo "  ✅ CSV export functionality"
echo ""
echo "🔗 Access points:"
echo "  • Admin Portal: http://localhost:8080/admin (or your production URL)"
echo "  • API Docs: http://localhost:8080/api/usage/stats"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your backend server:"
echo "     npm start"
echo ""
echo "  2. Login to admin portal:"
echo "     Navigate to /admin and login"
echo ""
echo "  3. Click 'API Usage' tab to view usage statistics"
echo ""
echo "  4. Test CSV export:"
echo "     Click 'Export Summary (CSV)' or 'Export Detailed (CSV)'"
echo ""
echo "  5. Verify tracking:"
echo "     Make an API call and check if usage is recorded"
echo ""
echo "📖 Documentation:"
echo "  Read TOKEN_TRACKING_SETUP.md for detailed usage instructions"
echo ""
echo "💡 Quick verification:"
echo "  SELECT COUNT(*) FROM user_api_usage;"
echo "  SELECT * FROM user_usage_summary LIMIT 5;"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

