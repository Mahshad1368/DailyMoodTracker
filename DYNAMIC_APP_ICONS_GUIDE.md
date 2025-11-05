# Dynamic App Icons Guide

This guide explains how to create and implement dynamic app icons for the Daily Mood Tracker app.

---

## Overview

The app icon automatically changes based on your **dominant mood** for the current day:
- Updates when you log a new mood entry
- Updates when you delete an entry
- Shows the mood you've logged most frequently today
- Default icon (Happy 😊) shown when no moods are logged

---

## Icon Design Specifications

### Required Sizes

For each mood variation, you need to create **5 icon files**:

| File Name | Size | Use Case |
|-----------|------|----------|
| `AppIcon-[Mood]@2x.png` | 120x120px | iPhone (Retina) |
| `AppIcon-[Mood]@3x.png` | 180x180px | iPhone (Retina HD) |
| `AppIcon-[Mood]-60@2x.png` | 120x120px | Spotlight/Settings |
| `AppIcon-[Mood]-60@3x.png` | 180x180px | Spotlight/Settings |
| `AppIcon-[Mood]-1024.png` | 1024x1024px | App Store (optional) |

**Replace `[Mood]` with**: `Happy`, `Neutral`, `Sad`, `Angry`, `Sleepy`

---

## Design Style Guide

### Mood 1: HAPPY 😊
- **Emoji**: 😊
- **Gradient**: Yellow (#FFD93D) → Peach (#FFAA80)
- **Mood**: Cheerful, optimistic, energetic
- **Background**: Warm, bright gradient
- **Use**: Most frequently happy entries

### Mood 2: NEUTRAL 😐
- **Emoji**: 😐
- **Gradient**: Light Blue (#A8D8EA) → Sky Blue (#6BA3BE)
- **Mood**: Calm, balanced, steady
- **Background**: Cool, tranquil gradient
- **Use**: Most frequently neutral entries

### Mood 3: SAD 😔
- **Emoji**: 😔
- **Gradient**: Lavender (#C8B6E2) → Light Purple (#9B7EBD)
- **Mood**: Melancholic, reflective, gentle
- **Background**: Soft purple gradient
- **Use**: Most frequently sad entries

### Mood 4: ANGRY 😡
- **Emoji**: 😡
- **Gradient**: Coral Red (#FF6B6B) → Deep Red (#E63946)
- **Mood**: Intense, fiery, passionate
- **Background**: Bold red gradient
- **Use**: Most frequently angry entries

### Mood 5: SLEEPY 😴
- **Emoji**: 😴
- **Gradient**: Beige (#F4E4C1) → Soft Gray (#C9C9C9)
- **Mood**: Tired, peaceful, restful
- **Background**: Muted, calming gradient
- **Use**: Most frequently sleepy entries

---

## Design Template

### Layout (All Icons)
```
┌─────────────────────┐
│                     │
│                     │
│         😊          │  ← Emoji centered
│                     │     (Size: ~60% of canvas)
│                     │
│    [GRADIENT]       │  ← Background gradient
│                     │
└─────────────────────┘
```

### Design Rules
1. **No text** - Only emoji and gradient
2. **Rounded square** - iOS automatically applies mask
3. **Flat design** - No 3D effects or shadows
4. **Centered emoji** - Perfect vertical/horizontal center
5. **Gradient direction** - Top-left to bottom-right (45°)
6. **Emoji size** - ~60-70% of canvas height
7. **No transparency** - Solid background required

---

## How to Create Icons

### Option 1: Using Figma (Recommended)

1. **Create new Figma file** with frame size 1024x1024px
2. **Add background rectangle** (1024x1024px)
3. **Apply linear gradient**:
   - Angle: 135° (top-left to bottom-right)
   - Color stops: See mood colors above
4. **Add emoji text**:
   - Font size: ~700px
   - Center align (vertical + horizontal)
   - Copy emoji from this guide
5. **Export**:
   - PNG format
   - 1x, 2x, 3x sizes
   - No transparency

### Option 2: Using Canva

1. Go to canva.com → Custom size → 1024x1024px
2. Add rectangle → Apply gradient (see colors)
3. Add text element → Insert emoji
4. Resize emoji to ~60% of canvas
5. Center emoji perfectly
6. Download → PNG → Transparent background OFF

### Option 3: Using AI (DALL-E, Midjourney, etc.)

**Prompt Template**:
```
Minimalist iOS app icon, 1024x1024px, rounded square,
centered [EMOJI] on smooth gradient background from
[COLOR 1] to [COLOR 2], flat design, no text, no shadows,
clean aesthetic, professional app icon style
```

**Example for Happy**:
```
Minimalist iOS app icon, 1024x1024px, rounded square,
centered 😊 emoji on smooth gradient background from
yellow #FFD93D to peach #FFAA80, flat design, no text,
no shadows, clean aesthetic, professional app icon style
```

---

## File Naming Convention

### For Each Mood, Create These Files:

#### Happy Icon:
- `AppIcon-Happy@2x.png` (120x120)
- `AppIcon-Happy@3x.png` (180x180)

#### Neutral Icon:
- `AppIcon-Neutral@2x.png` (120x120)
- `AppIcon-Neutral@3x.png` (180x180)

#### Sad Icon:
- `AppIcon-Sad@2x.png` (120x120)
- `AppIcon-Sad@3x.png` (180x180)

#### Angry Icon:
- `AppIcon-Angry@2x.png` (120x120)
- `AppIcon-Angry@3x.png` (180x180)

#### Sleepy Icon:
- `AppIcon-Sleepy@2x.png` (120x120)
- `AppIcon-Sleepy@3x.png` (180x180)

**Total**: 10 files minimum (2 per mood)

---

## Installation Steps

### 1. Add Icons to Xcode Project

1. Open Xcode project
2. Right-click on `DailyMoodTracker` folder
3. Select **"Add Files to DailyMoodTracker..."**
4. Select all 10 icon files
5. ✅ Check **"Copy items if needed"**
6. ✅ Check **"Add to targets: DailyMoodTracker"**
7. ✅ Ensure files are in project root (not in Assets.xcassets)

### 2. Verify Files Are Added

In Xcode Project Navigator, you should see:
```
DailyMoodTracker/
├── AppIcon-Happy@2x.png
├── AppIcon-Happy@3x.png
├── AppIcon-Neutral@2x.png
├── AppIcon-Neutral@3x.png
├── AppIcon-Sad@2x.png
├── AppIcon-Sad@3x.png
├── AppIcon-Angry@2x.png
├── AppIcon-Angry@3x.png
├── AppIcon-Sleepy@2x.png
├── AppIcon-Sleepy@3x.png
```

### 3. Update Build Settings

The project is already configured with:
- ✅ `Info.plist` with alternate icon entries
- ✅ `IconManager.swift` service for icon switching
- ✅ Integration with `DataManager` for automatic updates

---

## Testing

### Test on Device (Required)
**IMPORTANT**: Alternate app icons do NOT work in the iOS Simulator!

You MUST test on a **real iPhone** or **iPad**.

### Test Steps:

1. **Install app on your iPhone**
2. **Log a mood entry** (e.g., Happy 😊)
3. **Check home screen** - Icon should change to Happy gradient
4. **Log 2 more Sad entries** (😔)
5. **Check home screen** - Icon should change to Sad gradient
6. **Close and reopen app** - Icon persists
7. **Delete all entries**
8. **Icon remains** - Shows last dominant mood

### Console Output

When icon changes, you'll see in Xcode console:
```
🎨 Updating app icon based on mood...
📊 Dominant mood today: Happy (3 entries)
🔄 Changing icon to AppIcon-Happy...
✅ Successfully changed icon to AppIcon-Happy
```

---

## Default App Icon (App Store)

The default icon (in `Assets.xcassets/AppIcon`) should be the **Happy** variation:
- Use same design as AppIcon-Happy
- Required for App Store submission
- Shown before first mood is logged

### Sizes Required for Default Icon:

| Size | Use |
|------|-----|
| 20pt (40x40, 60x60) | iPad Notifications |
| 29pt (58x58, 87x87) | Settings |
| 40pt (80x80, 120x120) | Spotlight |
| 60pt (120x120, 180x180) | iPhone App Icon |
| 76pt (152x152) | iPad App Icon |
| 83.5pt (167x167) | iPad Pro |
| 1024x1024 | App Store |

---

## Color Reference Table

| Mood | Start Color | End Color | Hex Codes |
|------|-------------|-----------|-----------|
| Happy 😊 | Yellow | Peach | `#FFD93D` → `#FFAA80` |
| Neutral 😐 | Light Blue | Sky Blue | `#A8D8EA` → `#6BA3BE` |
| Sad 😔 | Lavender | Purple | `#C8B6E2` → `#9B7EBD` |
| Angry 😡 | Coral | Red | `#FF6B6B` → `#E63946` |
| Sleepy 😴 | Beige | Gray | `#F4E4C1` → `#C9C9C9` |

---

## Troubleshooting

### Icon Not Changing?

1. **Check console logs** - Look for 🎨 and ✅ messages
2. **Test on real device** - Simulator doesn't support alternate icons
3. **Verify files exist** - Check Xcode project for .png files
4. **Check Info.plist** - Ensure `CFBundleAlternateIcons` is configured
5. **Clean build** - Product → Clean Build Folder (⌘⇧K)

### Permission Alert Appears?

When iOS changes the app icon, it shows a system alert: **"[App Name] changed its icon"**

This is normal iOS behavior and cannot be disabled.

### Icon Reverts to Default?

- Icons persist across app launches
- Check if you deleted all mood entries
- Verify IconManager is being called after mood changes

---

## Advanced: Animated Icon Transitions

iOS does NOT support animated icon changes. The system alert interrupts the flow.

To minimize disruption:
- Icon updates happen automatically in background
- User doesn't need to manually trigger changes
- Updates are triggered by mood logging/deletion

---

## Future Enhancements

### Potential Features:
1. **Weekly dominant mood icon** - Icon reflects most common mood this week
2. **Manual icon selection** - Let users choose icon regardless of mood
3. **Seasonal variations** - Different gradient styles for seasons
4. **Streaks** - Special icon for 7-day logging streak
5. **Dark mode variants** - Darker gradients for dark mode

---

## Code Reference

### IconManager.swift:37

The icon selection logic:
```swift
static func forMood(_ mood: MoodType) -> AppIcon {
    switch mood {
    case .happy: return .happy
    case .neutral: return .neutral
    case .sad: return .sad
    case .angry: return .angry
    case .sleepy: return .sleepy
    }
}
```

### DataManager.swift:100

Automatic icon updates:
```swift
func addEntry(mood: MoodType, note: String) {
    let newEntry = MoodEntry(mood: mood, note: note)
    entries.insert(newEntry, at: 0)
    saveEntries()

    // Update app icon based on dominant mood
    IconManager.shared.updateIconForDominantMood(entries: entries)
}
```

---

## Resources

### Design Tools:
- **Figma**: [figma.com](https://figma.com) - Free for individuals
- **Canva**: [canva.com](https://canva.com) - Free with gradients
- **Sketch**: [sketch.com](https://sketch.com) - macOS only

### Icon Generators:
- **App Icon Generator**: [appicon.co](https://appicon.co)
- **MakeAppIcon**: [makeappicon.com](https://makeappicon.com)
- **Icon Kitchen**: [icon.kitchen](https://icon.kitchen)

### Gradient Tools:
- **CSS Gradient**: [cssgradient.io](https://cssgradient.io)
- **uiGradients**: [uigradients.com](https://uigradients.com)
- **Coolors**: [coolors.co](https://coolors.co/gradient-maker)

---

## Quick Start Checklist

- [ ] Create 5 icon designs (1 per mood)
- [ ] Export each icon as @2x (120x120) and @3x (180x180)
- [ ] Name files correctly (e.g., `AppIcon-Happy@2x.png`)
- [ ] Add all 10 files to Xcode project
- [ ] Build and install on real iPhone
- [ ] Log different moods and watch icon change
- [ ] Test that icon persists after app restart

---

## Need Help?

**Common Issues**:
- Icons not showing? → Check files are in project root, not Assets.xcassets
- App crashes? → Verify Info.plist has correct icon names
- Icon doesn't change? → Must test on real device, not simulator
- Blurry icons? → Ensure you created @2x and @3x versions

---

**Implementation Date**: 2025-11-04
**iOS Version**: 16.0+
**Status**: ✅ Code implemented, awaiting icon assets

---

Good luck creating your dynamic mood icons! 🎨✨
