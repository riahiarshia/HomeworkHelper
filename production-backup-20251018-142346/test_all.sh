#!/bin/bash

# Homework Helper Test Runner
# This script runs all tests with visible simulator

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Homework Helper Test Runner${NC}"
echo "=================================="

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${YELLOW}📁 Project directory: ${PROJECT_DIR}${NC}"

# Detect project file
if [ -d "${PROJECT_DIR}/HomeworkHelper.xcworkspace" ]; then
    PROJECT_FILE="${PROJECT_DIR}/HomeworkHelper.xcworkspace"
    PROJECT_TYPE="workspace"
    echo -e "${GREEN}✅ Found workspace: HomeworkHelper.xcworkspace${NC}"
elif [ -d "${PROJECT_DIR}/HomeworkHelper.xcodeproj" ]; then
    PROJECT_FILE="${PROJECT_DIR}/HomeworkHelper.xcodeproj"
    PROJECT_TYPE="project"
    echo -e "${GREEN}✅ Found project: HomeworkHelper.xcodeproj${NC}"
else
    echo -e "${RED}❌ No Xcode project or workspace found!${NC}"
    exit 1
fi

# Get available schemes
echo -e "${YELLOW}🔍 Detecting schemes...${NC}"
SCHEMES=$(xcodebuild -list -${PROJECT_TYPE} "${PROJECT_FILE}" | grep -A 10 "Schemes:" | tail -n +2 | grep -v "Build Configurations:" | xargs)

if [ -z "$SCHEMES" ]; then
    echo -e "${RED}❌ No schemes found!${NC}"
    exit 1
fi

# Use the first scheme (should be the main app scheme)
SCHEME=$(echo $SCHEMES | cut -d' ' -f1)
echo -e "${GREEN}✅ Using scheme: ${SCHEME}${NC}"

# Get available simulators
echo -e "${YELLOW}📱 Detecting available simulators...${NC}"
SIMULATORS=$(xcrun simctl list devices available | grep "iPhone" | head -5)

if [ -z "$SIMULATORS" ]; then
    echo -e "${RED}❌ No iOS simulators found!${NC}"
    exit 1
fi

# Use iPhone 15 if available, otherwise use the first iPhone
if echo "$SIMULATORS" | grep -q "iPhone 15"; then
    SIMULATOR_NAME="iPhone 15"
elif echo "$SIMULATORS" | grep -q "iPhone 14"; then
    SIMULATOR_NAME="iPhone 14"
elif echo "$SIMULATORS" | grep -q "iPhone SE"; then
    SIMULATOR_NAME="iPhone SE (3rd generation)"
else
    SIMULATOR_NAME=$(echo "$SIMULATORS" | head -1 | sed 's/.*iPhone/iPhone/' | sed 's/(.*)//' | xargs)
fi

echo -e "${GREEN}✅ Using simulator: ${SIMULATOR_NAME}${NC}"

# Create results directory
RESULTS_DIR="${PROJECT_DIR}/TestResults"
mkdir -p "$RESULTS_DIR"

# Generate timestamp for results
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULT_BUNDLE="${RESULTS_DIR}/${TIMESTAMP}.xcresult"

echo -e "${YELLOW}📊 Results will be saved to: ${RESULT_BUNDLE}${NC}"

# Kill any existing simulator processes
echo -e "${YELLOW}🔄 Cleaning up existing simulators...${NC}"
xcrun simctl shutdown all 2>/dev/null || true

# Open Simulator app to ensure it's visible
echo -e "${YELLOW}🚀 Opening Simulator app...${NC}"
open -a Simulator
sleep 3

# Boot the simulator
echo -e "${YELLOW}📱 Booting simulator: ${SIMULATOR_NAME}${NC}"
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || echo "Simulator already booted"

# Wait for simulator to be ready
echo -e "${YELLOW}⏳ Waiting for simulator to be ready...${NC}"
sleep 5

# Run the tests
echo -e "${BLUE}🧪 Running tests...${NC}"
echo "This may take several minutes. The simulator will remain visible throughout the test run."
echo ""

# Build the test command
TEST_COMMAND="xcodebuild test"
TEST_COMMAND+=" -${PROJECT_TYPE} \"${PROJECT_FILE}\""
TEST_COMMAND+=" -scheme \"${SCHEME}\""
TEST_COMMAND+=" -testPlan \"AppTests\""
TEST_COMMAND+=" -destination \"platform=iOS Simulator,name=${SIMULATOR_NAME},OS=latest\""
TEST_COMMAND+=" -resultBundlePath \"${RESULT_BUNDLE}\""
TEST_COMMAND+=" -quiet"

# Execute the test command
if eval "$TEST_COMMAND"; then
    echo ""
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo -e "${GREEN}📊 Test results saved to: ${RESULT_BUNDLE}${NC}"
    echo ""
    echo -e "${BLUE}📖 To view results:${NC}"
    echo "   open \"${RESULT_BUNDLE}\""
    echo ""
    echo -e "${BLUE}🔧 To run specific tests:${NC}"
    echo "   # Unit tests only:"
    echo "   xcodebuild test -${PROJECT_TYPE} \"${PROJECT_FILE}\" -scheme \"${SCHEME}\" -only-testing:HomeworkHelperTests"
    echo ""
    echo "   # UI tests only:"
    echo "   xcodebuild test -${PROJECT_TYPE} \"${PROJECT_FILE}\" -scheme \"${SCHEME}\" -only-testing:HomeworkHelperUITests"
    echo ""
    echo -e "${BLUE}🎯 To run tests on different simulators:${NC}"
    echo "   # List available simulators:"
    echo "   xcrun simctl list devices available"
    echo ""
    echo "   # Run on specific simulator:"
    echo "   xcodebuild test -${PROJECT_TYPE} \"${PROJECT_FILE}\" -scheme \"${SCHEME}\" -destination 'platform=iOS Simulator,name=iPhone SE,OS=latest'"
    
    # Keep simulator open for inspection
    echo ""
    echo -e "${YELLOW}💡 Simulator remains open for manual inspection${NC}"
    
else
    echo ""
    echo -e "${RED}❌ Tests failed!${NC}"
    echo -e "${RED}📊 Test results saved to: ${RESULT_BUNDLE}${NC}"
    echo ""
    echo -e "${BLUE}📖 To view failure details:${NC}"
    echo "   open \"${RESULT_BUNDLE}\""
    echo ""
    echo -e "${BLUE}🔧 To run failed tests again:${NC}"
    echo "   bash \"${SCRIPT_DIR}/test_all.sh\""
    
    exit 1
fi

echo -e "${GREEN}🎉 Test run completed!${NC}"
