#!/bin/bash

# Auto-resize app icons from 1024x1024 to required sizes
# Usage: ./resize_icons.sh

echo "📱 iOS App Icon Resizer"
echo "======================="
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick not found!"
    echo ""
    echo "Install with: brew install imagemagick"
    echo ""
    echo "Or use online tool: https://squoosh.app"
    exit 1
fi

echo "✅ ImageMagick found"
echo ""

# Check for source images
if [ ! -f "happy-1024.png" ] && [ ! -f "Happy-1024.png" ]; then
    echo "📋 Instructions:"
    echo "1. Generate 5 icons using AI (see AI_ICON_PROMPTS.md)"
    echo "2. Download them and rename to:"
    echo "   - happy-1024.png"
    echo "   - neutral-1024.png"
    echo "   - sad-1024.png"
    echo "   - angry-1024.png"
    echo "   - sleepy-1024.png"
    echo "3. Put them in this folder"
    echo "4. Run this script again"
    echo ""
    exit 0
fi

echo "🔄 Resizing icons..."
echo ""

# Function to resize icons
resize_icon() {
    local mood=$1
    local source=$2

    if [ ! -f "$source" ]; then
        echo "⚠️  Skipping $mood - source file not found: $source"
        return
    fi

    echo "Processing $mood..."

    # Create @2x version (120x120)
    convert "$source" -resize 120x120 "AppIcon-${mood}@2x.png"
    echo "  ✓ Created AppIcon-${mood}@2x.png (120x120)"

    # Create @3x version (180x180)
    convert "$source" -resize 180x180 "AppIcon-${mood}@3x.png"
    echo "  ✓ Created AppIcon-${mood}@3x.png (180x180)"

    echo ""
}

# Resize all moods
resize_icon "Happy" "happy-1024.png"
resize_icon "Neutral" "neutral-1024.png"
resize_icon "Sad" "sad-1024.png"
resize_icon "Angry" "angry-1024.png"
resize_icon "Sleepy" "sleepy-1024.png"

# Try alternate capitalized names if lowercase not found
resize_icon "Happy" "Happy-1024.png"
resize_icon "Neutral" "Neutral-1024.png"
resize_icon "Sad" "Sad-1024.png"
resize_icon "Angry" "Angry-1024.png"
resize_icon "Sleepy" "Sleepy-1024.png"

echo "✅ Done! Generated icon files:"
echo ""
ls -1 AppIcon-*.png 2>/dev/null | while read file; do
    size=$(identify -format "%wx%h" "$file" 2>/dev/null)
    echo "  $file ($size)"
done

echo ""
echo "📦 Next steps:"
echo "1. Open Xcode project"
echo "2. Drag all AppIcon-*.png files into project navigator"
echo "3. ✅ Check 'Copy items if needed'"
echo "4. ✅ Check 'Add to targets: DailyMoodTracker'"
echo "5. Build and run on your iPhone"
echo ""
echo "🎨 Your app icon will change based on your daily mood!"
