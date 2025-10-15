#!/bin/bash

# ========================================
# Maintain Environment Synchronization
# ========================================
# This script helps maintain synchronization between
# local development and Azure production environments
#
# Usage: ./scripts/maintain-sync.sh [command]
# Commands:
#   sync-db      - Sync production database to local
#   deploy       - Deploy local changes to production
#   setup        - Complete local setup from production
#   check        - Check synchronization status
#   help         - Show this help message

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "======================================"
echo "🔄 Environment Synchronization Manager"
echo "======================================"
echo ""

# Function to show help
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  ${CYAN}sync-db${NC}     - Sync production database to local"
    echo "  ${CYAN}deploy${NC}      - Deploy local changes to production"
    echo "  ${CYAN}setup${NC}       - Complete local setup from production"
    echo "  ${CYAN}check${NC}       - Check synchronization status"
    echo "  ${CYAN}help${NC}        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 sync-db              # Copy production DB to local"
    echo "  $0 deploy               # Deploy to Azure production"
    echo "  $0 setup                # Full local setup from production"
    echo "  $0 check                # Check if environments are in sync"
    echo ""
    echo "Environment Variables:"
    echo "  DATABASE_URL            - Production database connection string"
    echo "  NODE_ENV                - Environment (development/production)"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    local missing_deps=()
    
    # Check for required commands
    command -v psql >/dev/null 2>&1 || missing_deps+=("PostgreSQL client (psql)")
    command -v az >/dev/null 2>&1 || missing_deps+=("Azure CLI (az)")
    command -v git >/dev/null 2>&1 || missing_deps+=("Git")
    command -v node >/dev/null 2>&1 || missing_deps+=("Node.js")
    command -v npm >/dev/null 2>&1 || missing_deps+=("npm")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing dependencies:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        echo "Please install missing dependencies and try again."
        return 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites found${NC}"
    return 0
}

# Function to sync database
sync_database() {
    echo "🔄 Syncing production database to local..."
    echo ""
    
    if [ ! -f "$SCRIPT_DIR/sync-prod-to-local.sh" ]; then
        echo -e "${RED}❌ sync-prod-to-local.sh not found${NC}"
        return 1
    fi
    
    "$SCRIPT_DIR/sync-prod-to-local.sh"
}

# Function to deploy to production
deploy_to_production() {
    echo "🚀 Deploying to production..."
    echo ""
    
    if [ ! -f "$SCRIPT_DIR/deploy-to-azure.sh" ]; then
        echo -e "${RED}❌ deploy-to-azure.sh not found${NC}"
        return 1
    fi
    
    "$SCRIPT_DIR/deploy-to-azure.sh"
}

# Function to setup local environment
setup_local() {
    echo "🏗️  Setting up local environment from production..."
    echo ""
    
    if [ ! -f "$SCRIPT_DIR/setup-local-from-prod.sh" ]; then
        echo -e "${RED}❌ setup-local-from-prod.sh not found${NC}"
        return 1
    fi
    
    "$SCRIPT_DIR/setup-local-from-prod.sh"
}

# Function to check synchronization status
check_sync_status() {
    echo "🔍 Checking synchronization status..."
    echo ""
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ Not in a git repository${NC}"
        return 1
    fi
    
    # Check git status
    echo "📋 Git Status:"
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}⚠️  You have uncommitted changes:${NC}"
        git status --short
    else
        echo -e "${GREEN}✅ Working directory clean${NC}"
    fi
    
    # Check current branch
    local current_branch=$(git branch --show-current)
    echo "🌿 Current branch: $current_branch"
    
    # Check if we're up to date with remote
    echo ""
    echo "🔄 Remote Status:"
    git fetch --quiet
    
    local behind=$(git rev-list --count HEAD..origin/$current_branch 2>/dev/null || echo "0")
    local ahead=$(git rev-list --count origin/$current_branch..HEAD 2>/dev/null || echo "0")
    
    if [ "$behind" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $behind commits behind origin/$current_branch${NC}"
    fi
    
    if [ "$ahead" -gt 0 ]; then
        echo -e "${BLUE}ℹ️  $ahead commits ahead of origin/$current_branch${NC}"
    fi
    
    if [ "$behind" -eq 0 ] && [ "$ahead" -eq 0 ]; then
        echo -e "${GREEN}✅ Up to date with remote${NC}"
    fi
    
    # Check database connection
    echo ""
    echo "🗄️  Database Status:"
    
    # Check local database
    if psql -h localhost -p 5432 -U postgres -d homework_helper_dev -c "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Local database connection successful${NC}"
        
        # Count local tables
        local local_tables=$(psql -h localhost -p 5432 -U postgres -d homework_helper_dev -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null || echo "0")
        echo "  📊 Local tables: $local_tables"
    else
        echo -e "${RED}❌ Local database connection failed${NC}"
    fi
    
    # Check production database (if DATABASE_URL is set)
    if [ -n "$DATABASE_URL" ]; then
        if psql "$DATABASE_URL" -c "SELECT 1;" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Production database connection successful${NC}"
            
            # Count production tables
            local prod_tables=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null || echo "0")
            echo "  📊 Production tables: $prod_tables"
            
            # Compare table counts
            if [ "$local_tables" -eq "$prod_tables" ]; then
                echo -e "${GREEN}✅ Database schemas appear to match${NC}"
            else
                echo -e "${YELLOW}⚠️  Database schemas differ (local: $local_tables, prod: $prod_tables)${NC}"
                echo -e "${BLUE}💡 Run: $0 sync-db${NC}"
            fi
        else
            echo -e "${RED}❌ Production database connection failed${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  DATABASE_URL not set - cannot check production database${NC}"
    fi
    
    # Check environment files
    echo ""
    echo "⚙️  Environment Configuration:"
    
    if [ -f ".env.development" ]; then
        echo -e "${GREEN}✅ Local environment file exists${NC}"
    else
        echo -e "${YELLOW}⚠️  Local environment file missing${NC}"
        echo -e "${BLUE}💡 Run: $0 setup${NC}"
    fi
    
    if [ -f "package.json" ]; then
        echo -e "${GREEN}✅ Package.json found${NC}"
        
        # Check if node_modules exists
        if [ -d "node_modules" ]; then
            echo -e "${GREEN}✅ Dependencies installed${NC}"
        else
            echo -e "${YELLOW}⚠️  Dependencies not installed${NC}"
            echo -e "${BLUE}💡 Run: npm install${NC}"
        fi
    else
        echo -e "${RED}❌ Package.json not found${NC}"
    fi
    
    echo ""
    echo "📊 Synchronization Summary:"
    echo "  🔄 Code sync: $([ "$behind" -eq 0 ] && [ "$ahead" -eq 0 ] && echo "✅ Up to date" || echo "⚠️  Needs sync")"
    echo "  🗄️  Database sync: $([ "$local_tables" -eq "$prod_tables" ] && echo "✅ In sync" || echo "⚠️  Needs sync")"
    echo "  ⚙️  Environment: $([ -f ".env.development" ] && echo "✅ Configured" || echo "⚠️  Needs setup")"
    
    echo ""
}

# Main command processing
case "${1:-help}" in
    "sync-db")
        check_prerequisites && sync_database
        ;;
    "deploy")
        check_prerequisites && deploy_to_production
        ;;
    "setup")
        check_prerequisites && setup_local
        ;;
    "check")
        check_sync_status
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
