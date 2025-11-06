# 🎨 Widget Visual Design Specifications

## Daily Mood Tracker - Widget Mockups & Design Guide

This document provides visual descriptions and design specifications for all widget sizes.

---

## Widget Size Overview

### Available Sizes

| Widget Type | Size | Description | Use Case |
|------------|------|-------------|----------|
| **Small** | 2x2 | Single mood display | Quick mood glance |
| **Medium** | 4x2 | Mood + recent timeline | See recent patterns |
| **Large** | 4x4 | Full timeline with notes | Detailed day view |
| **Circular Lock** | Circle | Lock screen circular | iOS 16+ lock screen |
| **Rectangular Lock** | Rectangle | Lock screen wide | iOS 16+ lock screen |
| **Inline Lock** | Inline | Lock screen text | iOS 16+ lock screen |

---

## Small Widget (2x2)

### Visual Description

```
┌─────────────────────┐
│  [Gradient BG]      │
│                     │
│       😊            │
│      60x60          │
│                     │
│     Happy           │
│   (Bold, Large)     │
│                     │
│   3 entries         │
│  (Small, Light)     │
│                     │
└─────────────────────┘
```

### Layout Specifications

**Background:**
- Full gradient from top-left to bottom-right
- Colors based on dominant mood

**Emoji:**
- Size: 60x60 points
- Position: Centered horizontally, upper third vertically
- Custom image from Assets.xcassets

**Mood Name:**
- Font: System Rounded, Headline weight
- Color: White
- Position: Below emoji, centered

**Entry Count:**
- Font: System Rounded, Caption2
- Color: White 90% opacity
- Text: "{count} entry/entries" or "No mood yet"

### Example States

**Happy Mood (3 entries):**
```
Background: Yellow to Orange gradient
Emoji: 😊 (HappyEmoji)
Text: "Happy"
Subtext: "3 entries"
```

**No Mood State:**
```
Background: Blue gradient (Neutral default)
Emoji: 😐 (NeutralEmoji)
Text: "Neutral"
Subtext: "No mood yet"
```

---

## Medium Widget (4x2)

### Visual Description

```
┌──────────────────────────────────────────────┐
│  [Gradient Background]                       │
│                                              │
│  ┌────────┐ │  Recent Moods                 │
│  │  😊    │ │                               │
│  │ 50x50  │ │  😊 Happy      10:30 AM      │
│  │        │ │                               │
│  │ Happy  │ │  😐 Neutral    8:15 AM       │
│  │        │ │                               │
│  │3 today │ │  😊 Happy      7:00 AM       │
│  └────────┘ │                               │
│                                              │
└──────────────────────────────────────────────┘
```

### Layout Specifications

**Left Section (Dominant Mood):**
- Width: ~90 points
- Emoji: 50x50 points
- Name: Subheadline, Bold
- Count: Caption2, 90% opacity
- Vertical divider: White 30% opacity

**Right Section (Timeline):**
- Title: "Recent Moods" (Caption, Semibold, 90% opacity)
- Up to 3 most recent entries
- Each entry:
  - Emoji: 24x24 points
  - Mood name: Caption, Medium weight
  - Timestamp: Caption2, 80% opacity
  - Spacing: 8 points between entries

**Empty State:**
```
Right section shows:
  🙂 icon (30pt, 60% opacity)
  "No moods logged yet"
  (Caption, center-aligned)
```

---

## Large Widget (4x4)

### Visual Description

```
┌──────────────────────────────────────────────┐
│  [Gradient Background]                       │
│                                              │
│  Today's Mood           😊                   │
│  3 entries             40x40                 │
│                        Happy                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ 10:30 AM  😊  Happy                  │   │
│  │               Feeling great today!   │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ 8:15 AM   😐  Neutral                │   │
│  │               Just okay              │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ 7:00 AM   😊  Happy                  │   │
│  │                                      │   │
│  └──────────────────────────────────────┘   │
│                                              │
└──────────────────────────────────────────────┘
```

### Layout Specifications

**Header:**
- Left side: "Today's Mood" (Headline, Bold) + entry count (Caption)
- Right side: Dominant mood emoji (40x40) + name (Caption2)
- Divider: White 30% opacity line

**Timeline (Scrollable):**
- Each entry in card:
  - Time: Caption, Medium weight, 50pt width
  - Emoji: 28x28 points
  - Mood name: Subheadline, Semibold
  - Note: Caption, 80% opacity, 2 line limit
  - Card background: White 15% opacity
  - Card padding: 10pt horizontal, 6pt vertical
  - Card spacing: 12 points

**Empty State:**
```
Center of widget:
  🙂 icon (50pt, 60% opacity)
  "No moods logged today"
  (Body font)
  "Open the app to track your mood"
  (Caption, 70% opacity)
```

---

## Lock Screen Widgets (iOS 16+)

### Circular Lock Screen

```
┌─────────┐
│         │
│   😊    │
│  32x32  │
│         │
│    3    │
│ (Bold)  │
│         │
└─────────┘
```

**Specifications:**
- Background: AccessoryWidgetBackground
- Emoji: 32x32 points
- Count: Caption2, Bold
- Monochrome tinting when required

### Rectangular Lock Screen

```
┌────────────────────────────┐
│  😊  Happy                 │
│ 28x28  3 entries today     │
└────────────────────────────┘
```

**Specifications:**
- Height: Compact
- Emoji: 28x28 points
- Mood name: Caption, Semibold
- Count text: Caption2, Secondary color
- Horizontal padding: 8pt

### Inline Lock Screen

```
😊 Happy (3)
```

**Specifications:**
- Single line of text
- Emoji: 16x16 points inline
- Mood name: Caption font
- Count in parentheses: Caption2, Secondary

---

## Color Specifications

### Mood Gradients

**Happy:**
```
Start: #FFD93D (Bright Yellow)
End: #FFAA80 (Peach Orange)
Direction: Top-left to bottom-right
```

**Neutral:**
```
Start: #A8D8EA (Light Blue)
End: #6BA3BE (Medium Blue)
Direction: Top-left to bottom-right
```

**Sad:**
```
Start: #C8B6E2 (Light Purple)
End: #9B7EBD (Medium Purple)
Direction: Top-left to bottom-right
```

**Angry:**
```
Start: #FF6B6B (Bright Red)
End: #E63946 (Deep Red)
Direction: Top-left to bottom-right
```

**Sleepy:**
```
Start: #F4E4C1 (Cream)
End: #C9C9C9 (Light Gray)
Direction: Top-left to bottom-right
```

### Text Colors

**Primary Text:**
- Color: White #FFFFFF
- Opacity: 100%
- Use for: Mood names, headers

**Secondary Text:**
- Color: White #FFFFFF
- Opacity: 90%
- Use for: Subtitles, entry counts

**Tertiary Text:**
- Color: White #FFFFFF
- Opacity: 80%
- Use for: Notes, timestamps

**Dividers:**
- Color: White #FFFFFF
- Opacity: 30%
- Width: 1 point

**Card Backgrounds:**
- Color: White #FFFFFF
- Opacity: 15%
- Corner Radius: 8 points

---

## Typography Scale

### Font System: SF Rounded (System Design: Rounded)

**Large Title:**
- Use: Main headers
- Size: System .largeTitle
- Weight: Bold

**Headline:**
- Use: Section headers, mood names (Small widget)
- Size: System .headline
- Weight: Semibold

**Subheadline:**
- Use: Mood names (Medium widget), entry titles
- Size: System .subheadline
- Weight: Medium to Semibold

**Body:**
- Use: Empty state messages
- Size: System .body
- Weight: Regular

**Caption:**
- Use: Labels, timestamps, counts
- Size: System .caption
- Weight: Regular to Medium

**Caption2:**
- Use: Small labels, inline counts
- Size: System .caption2
- Weight: Regular

---

## Spacing System

### Padding

**Widget Padding:**
- Small: 15-20 points all sides
- Medium: 15-20 points all sides
- Large: 15-20 points all sides

**Card Padding:**
- Horizontal: 10 points
- Vertical: 6 points

**Element Spacing:**
- Between sections: 15-25 points
- Between items in list: 8-12 points
- Between icon and text: 8-12 points
- Between text lines: 2-4 points

### Margins

**Screen Edge:**
- Widgets handled by system
- Internal content: 15pt from edges

**Between Elements:**
- Major sections: 20pt
- Minor sections: 12pt
- List items: 8pt

---

## Interaction States

### Default State
- Normal colors and opacity
- Standard gradient background
- All elements visible

### Placeholder State (Loading)
- Show neutral gradient
- Display "Loading..." or skeleton
- Subdued colors

### Empty State (No Data)
- Neutral/default gradient
- Icon at 60% opacity
- Helpful message text
- Call-to-action text

### Error State
- Neutral gradient maintained
- Show error icon
- Brief error message
- "Try again" suggestion

---

## Animation Guidelines

### Widget Refresh
- Crossfade duration: 0.3 seconds
- Easing: Ease in-out
- No complex animations (battery impact)

### Timeline Updates
- New entry: Fade in from top
- Entry removal: Fade out
- Duration: 0.2 seconds

### Color Transitions
- Gradient change: 0.5 seconds
- Smooth blend between mood colors
- No abrupt switches

---

## Accessibility

### Color Contrast
- All text has minimum 4.5:1 contrast ratio
- Emoji provide additional context beyond color
- Gradients chosen for readability

### VoiceOver Labels
- Small widget: "Mood Tracker. {Mood name}. {Count} entries today"
- Medium widget: "{Mood name}. {Count} entries. Recent moods: {list}"
- Large widget: "Today's moods. {Count} entries. {Timeline list}"

### Dynamic Type
- All text scales with system font size
- Widget layout adjusts appropriately
- Minimum touch targets: 44x44 points

### Reduced Motion
- No spinning or complex animations
- Simple crossfades only
- Respect system settings

---

## Platform Considerations

### iOS 15.0 - 15.x
- Home screen widgets only
- Standard widget families
- No lock screen support

### iOS 16.0+
- All widget types supported
- Lock screen widgets available
- Enhanced customization
- Tinting support for lock screen

### Dark Mode
- Widgets use custom gradients (always)
- Don't follow system dark mode
- Consistent appearance day/night
- Text always white for contrast

---

## Design Best Practices

### Do's ✅
- Use high-quality emoji images (300x300px+)
- Keep text concise and scannable
- Maintain consistent spacing
- Test all mood states
- Ensure text is always readable
- Use semantic colors
- Provide clear empty states

### Don'ts ❌
- Don't use tiny fonts
- Don't overcrowd widgets
- Don't use complex animations
- Don't rely only on color
- Don't use low-res images
- Don't ignore empty states
- Don't make touch targets too small

---

## Testing Checklist

### Visual Testing
- [ ] All gradients display smoothly
- [ ] Text is crisp and readable
- [ ] Images are high quality
- [ ] Spacing is consistent
- [ ] Colors match specifications

### Functional Testing
- [ ] Data displays correctly
- [ ] Updates work reliably
- [ ] Empty states show properly
- [ ] All sizes work on all devices
- [ ] Lock screen widgets function (iOS 16+)

### Device Testing
- [ ] iPhone SE (small screen)
- [ ] iPhone 14/15 (standard screen)
- [ ] iPhone 14/15 Plus (large screen)
- [ ] iPhone 14/15 Pro Max (max screen)
- [ ] Different iOS versions

---

## Example Scenarios

### Scenario 1: Morning Mood Log

**Small Widget:**
```
Gradient: Yellow to Orange (Happy)
Emoji: 😊
Text: "Happy"
Count: "1 entry"
```

### Scenario 2: Stressful Day (Multiple Moods)

**Medium Widget:**
```
Dominant: 😡 Angry (logged 3x)
Timeline:
  😡 Angry    2:30 PM
  😡 Angry    11:00 AM
  😐 Neutral  7:30 AM
Background: Red gradient
```

### Scenario 3: Productive Day

**Large Widget:**
```
Header: "Today's Mood - 5 entries" + 😊
Timeline:
  5:00 PM  😊  Happy    "Finished project!"
  2:30 PM  😊  Happy    "Great lunch"
  12:00 PM 😐  Neutral  "Busy morning"
  9:00 AM  😊  Happy    "Good start"
  7:00 AM  😴  Sleepy   "Just woke up"
Background: Yellow gradient
```

---

## Resources

### Design Tools
- Figma widget templates (if available)
- Sketch widget templates (if available)
- Adobe XD widget templates (if available)

### Apple Resources
- Human Interface Guidelines: Widgets
- WidgetKit Documentation
- SF Symbols app for icons

### Testing Tools
- Xcode widget previews
- Physical devices (primary)
- Widget Gallery on device

---

**Ready to see your design come to life?**

Follow the WIDGET_SETUP_GUIDE.md to implement these specifications! 🎨

---

*Version: 1.0*
*Last Updated: November 2025*
