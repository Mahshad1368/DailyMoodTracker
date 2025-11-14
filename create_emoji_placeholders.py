#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os

# Create directory for emoji images
output_dir = "TempEmojiAssets"
os.makedirs(output_dir, exist_ok=True)

# Emoji definitions with colors
emojis = {
    "HappyEmoji": ("😊", (255, 217, 61)),      # Yellow
    "NeutralEmoji": ("😐", (168, 216, 234)),  # Blue
    "SadEmoji": ("😔", (200, 182, 226)),       # Purple
    "AngryEmoji": ("😡", (255, 107, 107)),     # Red
    "SleepyEmoji": ("😴", (244, 228, 193))      # Cream
}

# Create 300x300 images
size = 300

for name, (emoji, bg_color) in emojis.items():
    # Create image with colored background
    img = Image.new('RGB', (size, size), bg_color)
    draw = ImageDraw.Draw(img)
    
    # Try to use a large font for the emoji
    try:
        # Try to load a system font that supports emoji
        font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", 180)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Draw the emoji in the center
    text = emoji
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) / 2 - bbox[0]
    y = (size - text_height) / 2 - bbox[1]
    
    draw.text((x, y), text, fill=(0, 0, 0), font=font)
    
    # Save with transparency
    img = img.convert('RGBA')
    output_path = os.path.join(output_dir, f"{name}.png")
    img.save(output_path, 'PNG')
    print(f"✅ Created {output_path}")

print(f"\n✅ All emoji placeholders created in {output_dir}/")
