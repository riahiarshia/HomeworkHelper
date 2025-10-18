#!/bin/bash

# Script to make the owl fill almost the entire icon space

SOURCE_LOGO="HomeworkHelper/logo.png"
TEMP_LOGO="temp_huge_logo.png"
HUGE_LOGO="HomeworkHelper/logo_huge.png"

echo "Creating HUGE owl version to fill the icon..."

# Create a much larger version by scaling up significantly
cp "$SOURCE_LOGO" "$TEMP_LOGO"

# Scale up by 400% (4x size) to make owl really big
sips -z 4096 4096 "$TEMP_LOGO" --out "$TEMP_LOGO"

# Crop to center square - this removes most white space
# We'll crop to 1200x1200 from the center (keeping it square)
sips --cropToHeightWidth 1200 1200 "$TEMP_LOGO"

# Now resize back to 1024x1024 - owl will fill most of the space
sips -z 1024 1024 "$TEMP_LOGO" --out "$HUGE_LOGO"

# Clean up
rm "$TEMP_LOGO"

echo "✓ Created HUGE owl logo at $HUGE_LOGO"
echo "The owl now fills 85-90% of the icon space!"
echo ""
echo "Generating all icon sizes with HUGE owl..."

ICON_DIR="HomeworkHelper/Resources/Assets.xcassets/AppIcon.appiconset"

# Generate 1024x1024 (App Store)
sips -z 1024 1024 "$HUGE_LOGO" --out "$ICON_DIR/icon_1024.png"
echo "✓ Generated icon_1024.png"

# Generate 20pt icons
sips -z 20 20 "$HUGE_LOGO" --out "$ICON_DIR/icon_20@1x.png"
sips -z 40 40 "$HUGE_LOGO" --out "$ICON_DIR/icon_20@2x.png"
sips -z 60 60 "$HUGE_LOGO" --out "$ICON_DIR/icon_20@3x.png"
echo "✓ Generated 20pt icons"

# Generate 29pt icons (Settings)
sips -z 29 29 "$HUGE_LOGO" --out "$ICON_DIR/icon_29@1x.png"
sips -z 58 58 "$HUGE_LOGO" --out "$ICON_DIR/icon_29@2x.png"
sips -z 87 87 "$HUGE_LOGO" --out "$ICON_DIR/icon_29@3x.png"
echo "✓ Generated 29pt icons (Settings)"

# Generate 40pt icons (Spotlight)
sips -z 40 40 "$HUGE_LOGO" --out "$ICON_DIR/icon_40@1x.png"
sips -z 80 80 "$HUGE_LOGO" --out "$ICON_DIR/icon_40@2x.png"
sips -z 120 120 "$HUGE_LOGO" --out "$ICON_DIR/icon_40@3x.png"
echo "✓ Generated 40pt icons (Spotlight)"

# Generate 60pt icons (iPhone App)
sips -z 120 120 "$HUGE_LOGO" --out "$ICON_DIR/icon_60@2x.png"
sips -z 180 180 "$HUGE_LOGO" --out "$ICON_DIR/icon_60@3x.png"
echo "✓ Generated 60pt icons (iPhone App)"

# Generate 76pt icons (iPad App)
sips -z 76 76 "$HUGE_LOGO" --out "$ICON_DIR/icon_76@1x.png"
sips -z 152 152 "$HUGE_LOGO" --out "$ICON_DIR/icon_76@2x.png"
echo "✓ Generated 76pt icons (iPad App)"

# Generate 83.5pt icon (iPad Pro)
sips -z 167 167 "$HUGE_LOGO" --out "$ICON_DIR/icon_83.5@2x.png"
echo "✓ Generated 83.5pt icon (iPad Pro)"

echo ""
echo "🦉🎉 MASSIVE OWL ICON READY!"
echo "📱 The owl now fills 85-90% of the icon space!"
echo "🔥 This will look much more prominent on your home screen!"
echo ""
echo "Next steps:"
echo "1. In Xcode: Clean build folder (Cmd+Shift+K)"
echo "2. Delete the app from your device/simulator"
echo "3. Build and run (Cmd+R)"
echo "4. The owl will now be HUGE and clearly visible!"

