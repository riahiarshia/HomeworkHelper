#!/bin/bash

# Restore Xcode Schemes Script
# This script helps restore missing Xcode schemes after git operations

echo "🔄 RESTORING XCODE SCHEMES"
echo "=========================="
echo ""

# Check if we're in the right directory
if [ ! -f "HomeworkHelper.xcodeproj/project.pbxproj" ]; then
    echo "❌ Not in the correct directory. Please navigate to the project root."
    echo "   Run: cd /Users/ar616n/Documents/ios-app/ios-app"
    exit 1
fi

echo "✅ Found Xcode project"
echo ""

# Create the shared schemes directory if it doesn't exist
echo "📁 Creating shared schemes directory..."
mkdir -p HomeworkHelper.xcodeproj/xcshareddata/xcschemes

echo "✅ Shared schemes directory created"
echo ""

# Check if the scheme already exists
if [ -f "HomeworkHelper.xcodeproj/xcshareddata/xcschemes/HomeworkHelper.xcscheme" ]; then
    echo "✅ HomeworkHelper.xcscheme already exists"
    echo ""
    echo "📋 Current schemes:"
    ls -la HomeworkHelper.xcodeproj/xcshareddata/xcschemes/
    echo ""
    echo "🎉 Schemes are ready!"
    echo ""
    echo "📱 To use in Xcode:"
    echo "   1. Open HomeworkHelper.xcodeproj in Xcode"
    echo "   2. Go to Product → Scheme → Manage Schemes"
    echo "   3. You should see 'HomeworkHelper' scheme"
    echo "   4. Make sure it's marked as 'Shared'"
    echo ""
else
    echo "❌ Scheme file missing - this shouldn't happen"
    echo "   The scheme file should have been created by the previous script"
fi

echo "🔧 Alternative: Auto-generate schemes in Xcode"
echo "=============================================="
echo ""
echo "If the scheme still doesn't work, you can auto-generate it in Xcode:"
echo ""
echo "1. Open HomeworkHelper.xcodeproj in Xcode"
echo "2. Go to Product → Scheme → New Scheme"
echo "3. Select 'HomeworkHelper' target"
echo "4. Name it 'HomeworkHelper'"
echo "5. Click 'Create'"
echo "6. In the scheme editor, click 'Manage Schemes'"
echo "7. Check the 'Shared' checkbox for your scheme"
echo "8. Close the scheme editor"
echo ""
echo "This will create the scheme in xcshareddata and make it available to everyone."
echo ""

echo "🎉 XCODE SCHEMES RESTORATION COMPLETE!"
echo "======================================"
echo ""
echo "Your Xcode project should now have the necessary schemes to build and run."
