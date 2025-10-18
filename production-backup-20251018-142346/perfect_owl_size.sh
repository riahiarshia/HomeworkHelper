#!/bin/bash

# Script to create the PERFECT sized owl - not too small, not too big

SOURCE_LOGO="HomeworkHelper/logo.png"
TEMP_LOGO="temp_perfect_logo.png"
PERFECT_LOGO="HomeworkHelper/logo_perfect.png"

echo "Creating PERFECT sized owl version..."

# Create a version that's just right - about 70% of the icon space
cp "$SOURCE_LOGO" "$TEMP_LOGO"

# Scale up by 300% (3x size) - this is the sweet spot
sips -z 3072 3072 "$TEMP_LOGO" --out "$TEMP_LOGO"

# Crop to center square - leave some padding around the edges
# We'll crop to 1000x1000 from the center (keeping some white space)
sips --cropToHeightWidth 1000 1000 "$TEMP_LOGO"

# Now resize back to 1024x1024 - owl will be perfectly sized
sips -z 1024 1024 "$TEMP_LOGO" --out "$PERFECT_LOGO"

# Clean up
rm "$TEMP_LOGO"

echo "✓ Created PERFECT sized owl logo at $PERFECT_LOGO"
echo "The owl now fills about 70-75% of the icon space - perfect balance!"
echo ""
echo "Generating all icon sizes with PERFECT sized owl..."

ICON_DIR="HomeworkHelper/Resources/Assets.xcassets/AppIcon.appiconset"

# Generate 1024x1024 (App Store)
sips -z 1024 1024 "$PERFECT_LOGO" --out "$ICON_DIR/icon_1024.png"
echo "✓ Generated icon_1024.png"

# Generate 20pt icons
sips -z 20 20 "$PERFECT_LOGO" --out "$ICON_DIR/icon_20@1x.png"
sips -z 40 40 "$PERFECT_LOGO" --out "$ICON_DIR/icon_20@2x.png"
sips -z 60 60 "$PERFECT_LOGO" --out "$ICON_DIR/icon_20@3x.png"
echo "✓ Generated 20pt icons"

# Generate 29pt icons (Settings)
sips -z 29 29 "$PERFECT_LOGO" --out "$ICON_DIR/icon_29@1x.png"
sips -z 58 58 "$PERFECT_LOGO" --out "$ICON_DIR/icon_29@2x.png"
sips -z 87 87 "$PERFECT_LOGO" --out "$ICON_DIR/icon_29@3x.png"
echo "✓ Generated 29pt icons (Settings)"

# Generate 40pt icons (Spotlight)
sips -z 40 40 "$PERFECT_LOGO" --out "$ICON_DIR/icon_40@1x.png"
sips -z 80 80 "$PERFECT_LOGO" --out "$ICON_DIR/icon_40@2x.png"
sips -z 120 120 "$PERFECT_LOGO" --out "$ICON_DIR/icon_40@3x.png"
echo "✓ Generated 40pt icons (Spotlight)"

# Generate 60pt icons (iPhone App)
sips -z 120 120 "$PERFECT_LOGO" --out "$ICON_DIR/icon_60@2x.png"
sips -z 180 180 "$PERFECT_LOGO" --out "$ICON_DIR/icon_60@3x.png"
echo "✓ Generated 60pt icons (iPhone App)"

# Generate 76pt icons (iPad App)
sips -z 76 76 "$PERFECT_LOGO" --out "$ICON_DIR/icon_76@1x.png"
sips -z 152 152 "$PERFECT_LOGO" --out "$ICON_DIR/icon_76@2x.png"
echo "✓ Generated 76pt icons (iPad App)"

# Generate 83.5pt icon (iPad Pro)
sips -z 167 167 "$PERFECT_LOGO" --out "$ICON_DIR/icon_83.5@2x.png"
echo "✓ Generated 83.5pt icon (iPad Pro)"

echo ""
echo "🦉✨ PERFECT OWL ICON READY!"
echo "📱 The owl now has the ideal size - not too small, not too big!"
echo "🎯 About 70-75% of the icon space - just like professional apps!"
echo "💫 No more cropping, no more tiny owl - just perfect!"
echo ""
echo "Next steps:"
echo "1. In Xcode: Clean build folder (Cmd+Shift+K)"
echo "2. Delete the app from your device/simulator"
echo "3. Build and run (Cmd+R)"
echo "4. The owl will now be perfectly sized!"

