#!/bin/bash

# Automated Database Fix Deployment Script
# This script automatically fixes the staging database without manual intervention
# 
# Usage: ./deploy-auto-fix.sh
# 
# Requirements:
# - Must be run in Azure environment where DATABASE_URL is set
# - Requires Node.js and npm to be available

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Configuration
SCRIPT_NAME="auto-fix-database.js"
APP_NAME="homework-helper-staging"

echo "🚀 AUTOMATED DATABASE FIX DEPLOYMENT"
echo "===================================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Not in the backend directory. Please run this from the backend folder."
    exit 1
fi

# Check if the fix script exists
if [ ! -f "$SCRIPT_NAME" ]; then
    print_error "Fix script $SCRIPT_NAME not found!"
    exit 1
fi

print_info "Found fix script: $SCRIPT_NAME"

# Make the script executable
chmod +x "$SCRIPT_NAME"
print_success "Made script executable"

# Check environment variables
print_info "Checking environment variables..."
if [ -z "$DATABASE_URL" ]; then
    print_error "DATABASE_URL environment variable is not set!"
    print_warning "This script must be run in the Azure environment where DATABASE_URL is configured."
    exit 1
fi

print_success "DATABASE_URL is configured"

# Check if we have the required dependencies
print_info "Checking dependencies..."
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed or not in PATH"
    exit 1
fi

if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run 'npm install' first."
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    print_info "Installing dependencies..."
    npm install
    print_success "Dependencies installed"
fi

print_success "Dependencies check passed"

# Run the automated fix script
print_info "Running automated database fix..."
echo ""

if node "$SCRIPT_NAME"; then
    print_success "Automated database fix completed successfully!"
    echo ""
    print_info "🔑 Admin Portal Access:"
    print_info "   URL: https://$APP_NAME.azurewebsites.net/admin/"
    print_info "   Username: admin"
    print_info "   Password: Admin123!Staging"
    echo ""
    print_success "✅ Your admin portal should now be fully functional!"
    echo ""
    print_info "📝 What was fixed:"
    print_info "   - Created sample users for testing"
    print_info "   - Populated API usage analytics data"
    print_info "   - Added device login tracking data"
    print_info "   - Created sample promo codes"
    print_info "   - Set up database views for analytics"
    print_info "   - Verified admin user credentials"
    echo ""
    print_info "🔄 Please refresh your admin portal to see all the changes!"
else
    print_error "Failed to run automated database fix"
    print_warning "Check the error messages above for troubleshooting"
    exit 1
fi
