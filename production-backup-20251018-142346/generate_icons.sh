#!/bin/bash

# Script to generate all iOS app icon sizes from logo.png

SOURCE_LOGO="HomeworkHelper/logo.png"
ICON_DIR="HomeworkHelper/Resources/Assets.xcassets/AppIcon.appiconset"

# Check if source logo exists
if [ ! -f "$SOURCE_LOGO" ]; then
    echo "Error: Source logo not found at $SOURCE_LOGO"
    exit 1
fi

echo "Generating iOS app icons from $SOURCE_LOGO..."

# Generate 1024x1024 (App Store)
sips -z 1024 1024 "$SOURCE_LOGO" --out "$ICON_DIR/icon_1024.png"
echo "✓ Generated icon_1024.png"

# Generate 20pt icons
sips -z 20 20 "$SOURCE_LOGO" --out "$ICON_DIR/icon_20@1x.png"
sips -z 40 40 "$SOURCE_LOGO" --out "$ICON_DIR/icon_20@2x.png"
sips -z 60 60 "$SOURCE_LOGO" --out "$ICON_DIR/icon_20@3x.png"
echo "✓ Generated 20pt icons"

# Generate 29pt icons (Settings)
sips -z 29 29 "$SOURCE_LOGO" --out "$ICON_DIR/icon_29@1x.png"
sips -z 58 58 "$SOURCE_LOGO" --out "$ICON_DIR/icon_29@2x.png"
sips -z 87 87 "$SOURCE_LOGO" --out "$ICON_DIR/icon_29@3x.png"
echo "✓ Generated 29pt icons (Settings)"

# Generate 40pt icons (Spotlight)
sips -z 40 40 "$SOURCE_LOGO" --out "$ICON_DIR/icon_40@1x.png"
sips -z 80 80 "$SOURCE_LOGO" --out "$ICON_DIR/icon_40@2x.png"
sips -z 120 120 "$SOURCE_LOGO" --out "$ICON_DIR/icon_40@3x.png"
echo "✓ Generated 40pt icons (Spotlight)"

# Generate 60pt icons (iPhone App)
sips -z 120 120 "$SOURCE_LOGO" --out "$ICON_DIR/icon_60@2x.png"
sips -z 180 180 "$SOURCE_LOGO" --out "$ICON_DIR/icon_60@3x.png"
echo "✓ Generated 60pt icons (iPhone App)"

# Generate 76pt icons (iPad App)
sips -z 76 76 "$SOURCE_LOGO" --out "$ICON_DIR/icon_76@1x.png"
sips -z 152 152 "$SOURCE_LOGO" --out "$ICON_DIR/icon_76@2x.png"
echo "✓ Generated 76pt icons (iPad App)"

# Generate 83.5pt icon (iPad Pro)
sips -z 167 167 "$SOURCE_LOGO" --out "$ICON_DIR/icon_83.5@2x.png"
echo "✓ Generated 83.5pt icon (iPad Pro)"

echo ""
echo "🎉 All iOS app icons generated successfully!"
echo "📱 Your owl logo is now your app icon!"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Clean build folder (Cmd+Shift+K)"
echo "3. Build and run (Cmd+R)"
echo "4. Check your home screen to see the new icon!"

