#!/usr/bin/env python3
"""
Generate test app icons with gradient backgrounds and emojis
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_gradient(width, height, color1, color2):
    """Create a diagonal gradient from color1 to color2"""
    base = Image.new('RGB', (width, height), color1)
    top = Image.new('RGB', (width, height), color2)
    mask = Image.new('L', (width, height))
    mask_data = []
    for y in range(height):
        for x in range(width):
            # Diagonal gradient
            progress = (x + y) / (width + height)
            mask_data.append(int(255 * progress))
    mask.putdata(mask_data)
    base.paste(top, (0, 0), mask)
    return base

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_icon(mood_name, emoji, color1_hex, color2_hex, size):
    """Create icon with gradient and emoji"""
    color1 = hex_to_rgb(color1_hex)
    color2 = hex_to_rgb(color2_hex)

    img = create_gradient(size, size, color1, color2)
    draw = ImageDraw.Draw(img)

    # Try to load system font for emoji
    try:
        # macOS system emoji font
        font_size = int(size * 0.6)
        font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", font_size)
    except:
        try:
            # Fallback to default
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(size * 0.5))
        except:
            # Use default PIL font
            font = ImageFont.load_default()

    # Calculate text position (centered)
    bbox = draw.textbbox((0, 0), emoji, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2 - bbox[0]
    y = (size - text_height) // 2 - bbox[1]

    # Draw emoji
    draw.text((x, y), emoji, font=font, embedded_color=True)

    return img

# Icon configurations
icons = {
    'Happy': {
        'emoji': '😊',
        'color1': '#FFD93D',  # Yellow
        'color2': '#FFAA80'   # Peach
    },
    'Neutral': {
        'emoji': '😐',
        'color1': '#A8D8EA',  # Light Blue
        'color2': '#6BA3BE'   # Sky Blue
    },
    'Sad': {
        'emoji': '😔',
        'color1': '#C8B6E2',  # Lavender
        'color2': '#9B7EBD'   # Purple
    },
    'Angry': {
        'emoji': '😡',
        'color1': '#FF6B6B',  # Coral
        'color2': '#E63946'   # Red
    },
    'Sleepy': {
        'emoji': '😴',
        'color1': '#F4E4C1',  # Beige
        'color2': '#C9C9C9'   # Gray
    }
}

print("🎨 Creating test app icons...")
print("=" * 50)

# Create icons in required sizes
for mood, config in icons.items():
    print(f"\n📱 Creating {mood} icons...")

    # @2x version (120x120)
    img_2x = create_icon(mood, config['emoji'], config['color1'], config['color2'], 120)
    filename_2x = f"AppIcon-{mood}@2x.png"
    img_2x.save(filename_2x)
    print(f"  ✓ {filename_2x} (120x120)")

    # @3x version (180x180)
    img_3x = create_icon(mood, config['emoji'], config['color1'], config['color2'], 180)
    filename_3x = f"AppIcon-{mood}@3x.png"
    img_3x.save(filename_3x)
    print(f"  ✓ {filename_3x} (180x180)")

print("\n" + "=" * 50)
print("✅ All icons created successfully!")
print("\n📦 Generated files:")
for mood in icons.keys():
    print(f"  - AppIcon-{mood}@2x.png")
    print(f"  - AppIcon-{mood}@3x.png")

print("\n🚀 Next steps:")
print("1. Drag all 10 PNG files into Xcode project")
print("2. ✅ Check 'Copy items if needed'")
print("3. ✅ Check 'Add to targets: DailyMoodTracker'")
print("4. Build and run on your iPhone")
print("5. Log moods and watch your app icon change! 🎨")
