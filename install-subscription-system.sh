#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║  📚 Homework Helper - Subscription System Installer   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Install PostgreSQL
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Installing PostgreSQL Database..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v psql &> /dev/null; then
    echo "PostgreSQL not found. Installing via Homebrew..."
    brew install postgresql@15
    brew services start postgresql@15
    echo -e "${GREEN}✅ PostgreSQL installed and started${NC}"
else
    echo -e "${GREEN}✅ PostgreSQL already installed${NC}"
    # Make sure it's running
    brew services start postgresql@15 2>/dev/null || true
fi

# Wait a moment for PostgreSQL to start
sleep 2

# Step 2: Create Database
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Creating Database..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create database (will fail if exists, that's ok)
createdb homework_helper 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database 'homework_helper' created${NC}"
else
    echo -e "${YELLOW}⚠️  Database 'homework_helper' already exists${NC}"
fi

# Step 3: Run Migration
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Creating Database Tables..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "backend/database/migration.sql" ]; then
    psql homework_helper -f backend/database/migration.sql
    echo -e "${GREEN}✅ Database tables created${NC}"
else
    echo -e "${RED}❌ Migration file not found${NC}"
    exit 1
fi

# Step 4: Install Node.js Dependencies
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Installing Backend Dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd backend

# Rename package file if needed
if [ -f "package-subscription.json" ]; then
    cp package-subscription.json package.json
fi

npm install

echo -e "${GREEN}✅ Dependencies installed${NC}"

# Step 5: Setup Environment Variables
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5: Setting up Environment Variables..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f ".env" ]; then
    # Generate random JWT secrets
    JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
    ADMIN_JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
    
    cat > .env << EOF
# Server Configuration
PORT=3000
NODE_ENV=development
APP_URL=http://localhost:3000

# Database Configuration (Local PostgreSQL)
DB_USER=$(whoami)
DB_HOST=localhost
DB_NAME=homework_helper
DB_PASSWORD=
DB_PORT=5432

# JWT Secrets (Auto-generated)
JWT_SECRET=${JWT_SECRET}
ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET}

# Stripe Configuration (Add your keys from stripe.com)
STRIPE_SECRET_KEY=sk_test_your_stripe_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
STRIPE_PRICE_ID=price_your_price_id_here
EOF
    
    echo -e "${GREEN}✅ .env file created${NC}"
    echo -e "${YELLOW}⚠️  Note: Update Stripe keys in backend/.env when ready${NC}"
else
    echo -e "${YELLOW}⚠️  .env file already exists (not overwriting)${NC}"
fi

cd ..

# Step 6: Summary
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ INSTALLATION COMPLETE!                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🎉 Your subscription system is ready!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 WHERE EVERYTHING IS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Database:"
echo "   Name: homework_helper"
echo "   Location: Local PostgreSQL"
echo "   Access: psql homework_helper"
echo ""
echo "🌐 Admin Dashboard:"
echo "   Location: backend/public/admin/"
echo "   Will be at: http://localhost:3000/admin"
echo ""
echo "🖥️  Backend Server:"
echo "   Location: backend/"
echo "   Config: backend/.env"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 NEXT STEPS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Start the backend server:"
echo "   cd backend"
echo "   npm start"
echo ""
echo "2️⃣  Open admin dashboard in browser:"
echo "   http://localhost:3000/admin"
echo ""
echo "3️⃣  Login with:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "4️⃣  IMPORTANT: Change admin password immediately!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 For full documentation, see:"
echo "   - SUBSCRIPTION_SYSTEM_GUIDE.md (complete guide)"
echo "   - QUICK_START_SUBSCRIPTION.md (quick reference)"
echo ""
echo "Ready to start! Run: cd backend && npm start"
echo ""


