#!/bin/bash

# Widget Assets.xcassets directory
ASSETS_DIR="MoodTrackerWidget/Assets.xcassets"

# Create Contents.json for the asset catalog
cat > "$ASSETS_DIR/Contents.json" << 'CATALOG_JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
CATALOG_JSON

echo "✅ Created Contents.json for asset catalog"

# Create AppIcon imageset (empty, but required)
mkdir -p "$ASSETS_DIR/AppIcon.appiconset"
cat > "$ASSETS_DIR/AppIcon.appiconset/Contents.json" << 'APPICON_JSON'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
APPICON_JSON

echo "✅ Created AppIcon imageset"

# Create AccentColor colorset
mkdir -p "$ASSETS_DIR/AccentColor.colorset"
cat > "$ASSETS_DIR/AccentColor.colorset/Contents.json" << 'ACCENT_JSON'
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
ACCENT_JSON

echo "✅ Created AccentColor colorset"

# Array of emoji names
emojis=("HappyEmoji" "NeutralEmoji" "SadEmoji" "AngryEmoji" "SleepyEmoji")

# Create imageset for each emoji
for emoji in "${emojis[@]}"; do
    IMAGESET_DIR="$ASSETS_DIR/${emoji}.imageset"
    mkdir -p "$IMAGESET_DIR"
    
    # Copy the placeholder image
    if [ -f "TempEmojiAssets/${emoji}.png" ]; then
        cp "TempEmojiAssets/${emoji}.png" "$IMAGESET_DIR/${emoji}.png"
        echo "✅ Copied ${emoji}.png"
    else
        echo "⚠️  Warning: TempEmojiAssets/${emoji}.png not found"
    fi
    
    # Create Contents.json for this imageset
    cat > "$IMAGESET_DIR/Contents.json" << EOF_JSON
{
  "images" : [
    {
      "filename" : "${emoji}.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF_JSON
    
    echo "✅ Created ${emoji} imageset"
done

echo ""
echo "🎉 Widget assets setup complete!"
echo "📂 Assets location: $ASSETS_DIR"
echo ""
echo "Asset structure:"
tree -L 2 "$ASSETS_DIR" 2>/dev/null || find "$ASSETS_DIR" -type f -o -type d | sort

