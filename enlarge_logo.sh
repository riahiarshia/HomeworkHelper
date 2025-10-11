#!/bin/bash

# Script to create a larger version of the logo by cropping white space and scaling up

SOURCE_LOGO="HomeworkHelper/logo.png"
TEMP_LOGO="temp_enlarged_logo.png"
ENLARGED_LOGO="HomeworkHelper/logo_enlarged.png"

echo "Creating enlarged version of logo..."

# First, let's get the original dimensions
ORIGINAL_SIZE=$(sips -g pixelWidth -g pixelHeight "$SOURCE_LOGO" | grep -E "pixelWidth|pixelHeight" | awk '{print $2}')
echo "Original dimensions: $ORIGINAL_SIZE"

# Create a copy and add padding, then crop to remove excess white space
# This effectively makes the owl larger relative to the canvas
cp "$SOURCE_LOGO" "$TEMP_LOGO"

# Scale up the image by 200% (double size)
sips -z 2048 2048 "$TEMP_LOGO" --out "$TEMP_LOGO"

# Crop to center square (removes extra white space)
sips --cropToHeightWidth 1800 1800 "$TEMP_LOGO"

# Now resize back to 1024x1024 (owl will appear much larger)
sips -z 1024 1024 "$TEMP_LOGO" --out "$ENLARGED_LOGO"

# Clean up
rm "$TEMP_LOGO"

echo "✓ Created enlarged logo at $ENLARGED_LOGO"
echo ""
echo "Now generating all icon sizes from enlarged logo..."

# Now use the enlarged logo to generate all icon sizes
ICON_DIR="HomeworkHelper/Resources/Assets.xcassets/AppIcon.appiconset"

# Generate 1024x1024 (App Store)
sips -z 1024 1024 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_1024.png"
echo "✓ Generated icon_1024.png"

# Generate 20pt icons
sips -z 20 20 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_20@1x.png"
sips -z 40 40 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_20@2x.png"
sips -z 60 60 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_20@3x.png"
echo "✓ Generated 20pt icons"

# Generate 29pt icons (Settings)
sips -z 29 29 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_29@1x.png"
sips -z 58 58 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_29@2x.png"
sips -z 87 87 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_29@3x.png"
echo "✓ Generated 29pt icons (Settings)"

# Generate 40pt icons (Spotlight)
sips -z 40 40 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_40@1x.png"
sips -z 80 80 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_40@2x.png"
sips -z 120 120 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_40@3x.png"
echo "✓ Generated 40pt icons (Spotlight)"

# Generate 60pt icons (iPhone App)
sips -z 120 120 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_60@2x.png"
sips -z 180 180 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_60@3x.png"
echo "✓ Generated 60pt icons (iPhone App)"

# Generate 76pt icons (iPad App)
sips -z 76 76 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_76@1x.png"
sips -z 152 152 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_76@2x.png"
echo "✓ Generated 76pt icons (iPad App)"

# Generate 83.5pt icon (iPad Pro)
sips -z 167 167 "$ENLARGED_LOGO" --out "$ICON_DIR/icon_83.5@2x.png"
echo "✓ Generated 83.5pt icon (iPad Pro)"

echo ""
echo "🎉 All iOS app icons regenerated with larger owl!"
echo "📱 The owl is now 2x larger in the icon!"
echo ""
echo "Next steps:"
echo "1. In Xcode: Clean build folder (Cmd+Shift+K)"
echo "2. Delete the app from your device/simulator"
echo "3. Build and run (Cmd+R)"
echo "4. The owl will now appear much larger!"

