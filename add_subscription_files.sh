#!/bin/bash

# Script to add subscription files to Xcode project
# This adds the new Swift files to the project so they compile

echo "🔧 Adding subscription files to Xcode project..."

cd /Users/ar616n/Documents/ios-app/ios-app

# Check if files exist
if [ ! -f "HomeworkHelper/Services/SubscriptionService.swift" ]; then
    echo "❌ Error: SubscriptionService.swift not found"
    exit 1
fi

if [ ! -f "HomeworkHelper/Views/PaywallView.swift" ]; then
    echo "❌ Error: PaywallView.swift not found"
    exit 1
fi

if [ ! -f "HomeworkHelper/Configuration.storekit" ]; then
    echo "❌ Error: Configuration.storekit not found"
    exit 1
fi

echo "✅ All files found"
echo ""
echo "📋 MANUAL STEPS REQUIRED:"
echo ""
echo "1. In Xcode, right-click on the 'Services' folder"
echo "   → Select 'Add Files to HomeworkHelper...'"
echo "   → Navigate to: HomeworkHelper/Services/SubscriptionService.swift"
echo "   → Make sure 'Copy items if needed' is UNCHECKED (file is already in place)"
echo "   → Click 'Add'"
echo ""
echo "2. In Xcode, right-click on the 'Views' folder"
echo "   → Select 'Add Files to HomeworkHelper...'"
echo "   → Navigate to: HomeworkHelper/Views/PaywallView.swift"
echo "   → Make sure 'Copy items if needed' is UNCHECKED"
echo "   → Click 'Add'"
echo ""
echo "3. In Xcode, right-click on the project root (HomeworkHelper)"
echo "   → Select 'Add Files to HomeworkHelper...'"
echo "   → Navigate to: HomeworkHelper/Configuration.storekit"
echo "   → Make sure 'Copy items if needed' is UNCHECKED"
echo "   → Click 'Add'"
echo ""
echo "4. Build the project (Cmd+B)"
echo ""
echo "✅ Files are ready to be added!"
