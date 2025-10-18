#!/bin/bash

# Comprehensive Auto-Fix and Testing Script
# This script will automatically fix deployment issues, test everything, and ensure admin audit logging works
# It will continue until everything is fixed, with automatic retries on network errors

set -e

echo "🚀 COMPREHENSIVE AUTO-FIX AND TESTING SCRIPT"
echo "============================================="
echo "Starting automated fix process..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
attempt=0
max_attempts=50
deployment_success=false
audit_table_fixed=false
ledger_working=false
admin_portal_working=false

# Function to log with timestamp
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check deployment status
check_deployment_status() {
    local latest_run=$(gh run list --limit 1 --json databaseId,status,conclusion,workflowName,headBranch,createdAt 2>/dev/null || echo "[]")
    
    if [[ "$latest_run" == "[]" ]]; then
        return 1
    fi
    
    local status=$(echo "$latest_run" | jq -r '.[0].status')
    local conclusion=$(echo "$latest_run" | jq -r '.[0].conclusion')
    
    if [[ "$status" == "completed" && "$conclusion" == "success" ]]; then
        return 0
    elif [[ "$status" == "completed" && "$conclusion" == "failure" ]]; then
        return 2
    else
        return 1
    fi
}

# Function to test application health
test_app_health() {
    local response=$(curl -s --max-time 10 https://homework-helper-api.azurewebsites.net/api/health 2>/dev/null || echo "error")
    
    if [[ "$response" == "error" ]]; then
        return 1
    fi
    
    local status=$(echo "$response" | jq -r '.status' 2>/dev/null || echo "unknown")
    
    if [[ "$status" == "ok" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to test ledger endpoints
test_ledger_endpoints() {
    local public_stats=$(curl -s --max-time 10 https://homework-helper-api.azurewebsites.net/api/ledger/public-stats 2>/dev/null || echo "error")
    local system_info=$(curl -s --max-time 10 https://homework-helper-api.azurewebsites.net/api/ledger/system-info 2>/dev/null || echo "error")
    
    if [[ "$public_stats" == "error" || "$system_info" == "error" ]]; then
        return 1
    fi
    
    local stats_success=$(echo "$public_stats" | jq -r '.success' 2>/dev/null || echo "false")
    local info_success=$(echo "$system_info" | jq -r '.success' 2>/dev/null || echo "false")
    
    if [[ "$stats_success" == "true" && "$info_success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to test admin portal
test_admin_portal() {
    local response=$(curl -s --max-time 10 https://homework-helper-api.azurewebsites.net/admin/ 2>/dev/null || echo "error")
    
    if [[ "$response" == "error" ]]; then
        return 1
    fi
    
    if [[ "$response" == *"Admin Dashboard"* ]]; then
        return 0
    else
        return 1
    fi
}

# Function to fix admin audit table
fix_admin_audit_table() {
    log "${BLUE}🔧 Attempting to fix admin audit table...${NC}"
    
    local response=$(curl -s --max-time 30 https://homework-helper-api.azurewebsites.net/api/ledger/fix-admin-audit 2>/dev/null || echo "error")
    
    if [[ "$response" == "error" ]]; then
        log "${RED}❌ Failed to call fix endpoint${NC}"
        return 1
    fi
    
    local success=$(echo "$response" | jq -r '.success' 2>/dev/null || echo "false")
    
    if [[ "$success" == "true" ]]; then
        log "${GREEN}✅ Admin audit table fixed successfully${NC}"
        return 0
    else
        log "${RED}❌ Admin audit table fix failed${NC}"
        return 1
    fi
}

# Function to deploy changes
deploy_changes() {
    log "${BLUE}🚀 Deploying changes...${NC}"
    
    # Check if there are any changes to commit
    if git diff --quiet && git diff --cached --quiet; then
        log "${YELLOW}⚠️ No changes to deploy${NC}"
        return 0
    fi
    
    # Commit any changes
    git add -A
    git commit -m "Auto-fix: $(date '+%Y-%m-%d %H:%M:%S')" || true
    
    # Push changes
    git push origin main
    
    log "${GREEN}✅ Changes pushed to repository${NC}"
    return 0
}

# Function to wait for deployment
wait_for_deployment() {
    local timeout=300 # 5 minutes
    local start_time=$(date +%s)
    
    log "${BLUE}⏳ Waiting for deployment to complete...${NC}"
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [[ $elapsed -gt $timeout ]]; then
            log "${RED}❌ Deployment timeout after 5 minutes${NC}"
            return 1
        fi
        
        check_deployment_status
        local status=$?
        
        if [[ $status -eq 0 ]]; then
            log "${GREEN}✅ Deployment completed successfully${NC}"
            return 0
        elif [[ $status -eq 2 ]]; then
            log "${RED}❌ Deployment failed${NC}"
            return 1
        fi
        
        log "${BLUE}⏳ Deployment in progress... (${elapsed}s elapsed)${NC}"
        sleep 10
    done
}

# Function to handle network errors
handle_network_error() {
    log "${YELLOW}⚠️ Network error detected, waiting 60 seconds before retry...${NC}"
    sleep 60
}

# Main testing and fixing loop
main() {
    log "${GREEN}🚀 Starting comprehensive auto-fix process${NC}"
    log "${BLUE}Target: https://homework-helper-api.azurewebsites.net${NC}"
    log "${BLUE}Admin Portal: https://homework-helper-api.azurewebsites.net/admin/${NC}"
    echo ""
    
    # Set up error handling
    trap handle_network_error ERR
    
    while [[ $attempt -lt $max_attempts ]]; do
        attempt=$((attempt + 1))
        
        log "${BLUE}🔄 Auto-fix attempt #$attempt${NC}"
        echo ""
        
        # Step 1: Check current deployment status
        log "${BLUE}📊 Checking deployment status...${NC}"
        check_deployment_status
        local deploy_status=$?
        
        if [[ $deploy_status -eq 0 ]]; then
            deployment_success=true
            log "${GREEN}✅ Deployment is successful${NC}"
        elif [[ $deploy_status -eq 2 ]]; then
            log "${RED}❌ Deployment failed, attempting to fix...${NC}"
            deploy_changes
            wait_for_deployment
        else
            log "${YELLOW}⏳ Deployment in progress...${NC}"
        fi
        
        # Step 2: Test application health
        log "${BLUE}🏥 Testing application health...${NC}"
        if test_app_health; then
            log "${GREEN}✅ Application is healthy${NC}"
        else
            log "${RED}❌ Application health check failed${NC}"
            sleep 30
            continue
        fi
        
        # Step 3: Test ledger endpoints
        log "${BLUE}📋 Testing ledger endpoints...${NC}"
        if test_ledger_endpoints; then
            ledger_working=true
            log "${GREEN}✅ Ledger endpoints working${NC}"
        else
            log "${RED}❌ Ledger endpoints failed${NC}"
            sleep 30
            continue
        fi
        
        # Step 4: Test admin portal
        log "${BLUE}🔧 Testing admin portal...${NC}"
        if test_admin_portal; then
            admin_portal_working=true
            log "${GREEN}✅ Admin portal accessible${NC}"
        else
            log "${RED}❌ Admin portal failed${NC}"
            sleep 30
            continue
        fi
        
        # Step 5: Fix admin audit table
        log "${BLUE}🔧 Testing admin audit table...${NC}"
        if fix_admin_audit_table; then
            audit_table_fixed=true
            log "${GREEN}✅ Admin audit table working${NC}"
        else
            log "${YELLOW}⚠️ Admin audit table needs fixing${NC}"
            # Try to deploy the fix
            deploy_changes
            wait_for_deployment
            continue
        fi
        
        # Step 6: Final verification
        log "${BLUE}🔍 Running final verification...${NC}"
        
        # Test all components again
        if test_app_health && test_ledger_endpoints && test_admin_portal && fix_admin_audit_table; then
            log "${GREEN}🎉 ALL SYSTEMS WORKING!${NC}"
            echo ""
            log "${GREEN}✅ Deployment: Working${NC}"
            log "${GREEN}✅ Application Health: Working${NC}"
            log "${GREEN}✅ Ledger System: Working${NC}"
            log "${GREEN}✅ Admin Portal: Working${NC}"
            log "${GREEN}✅ Admin Audit Logging: Working${NC}"
            echo ""
            log "${GREEN}🚀 SYSTEM FULLY OPERATIONAL${NC}"
            break
        else
            log "${RED}❌ Final verification failed, retrying...${NC}"
            sleep 30
            continue
        fi
    done
    
    if [[ $attempt -ge $max_attempts ]]; then
        log "${RED}❌ Maximum attempts reached. Manual intervention may be required.${NC}"
        exit 1
    fi
}

# Run the main function
main "$@"
