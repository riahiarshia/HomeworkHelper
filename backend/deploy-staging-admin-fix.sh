#!/bin/bash

# Deploy Staging Admin Portal Fix
# This script will fix the staging admin portal database connection and admin user

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
APP_NAME="homework-helper-staging"
SCRIPT_NAME="fix-staging-admin-portal.js"

echo "🚀 Deploying Staging Admin Portal Fix"
echo "====================================="
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

# Run the fix script
print_info "Running staging admin portal fix..."
echo ""

if node "$SCRIPT_NAME"; then
    print_success "Staging admin portal fix completed successfully!"
    echo ""
    print_info "🔑 Admin Portal Access:"
    print_info "   URL: https://$APP_NAME.azurewebsites.net/admin/"
    print_info "   Username: admin"
    print_info "   Password: Admin123!Staging"
    echo ""
    print_success "✅ You can now login to the admin portal!"
    echo ""
    print_info "📝 Next Steps:"
    print_info "1. Go to the admin portal URL above"
    print_info "2. Use the credentials provided"
    print_info "3. Verify you can access the dashboard"
    print_info "4. Check that user management functions work"
else
    print_error "Failed to run staging admin portal fix"
    print_warning "You may need to run the script manually via Azure Kudu console"
    print_warning "Go to: https://$APP_NAME.scm.azurewebsites.net"
    print_warning "Then run: node $SCRIPT_NAME"
    exit 1
fi
