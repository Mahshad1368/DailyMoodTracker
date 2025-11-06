# 📄 Quick Reference Card

## Daily Mood Tracker Widget - One-Page Cheat Sheet

**Print this page and keep it handy during setup!**

---

## Essential Information

**App Group ID:** `group.com.dailymoodtracker.app`
**Widget Bundle ID:** `com.yourapp.DailyMoodTracker.MoodTrackerWidget`
**Minimum iOS:** 15.0 (16.0 for lock screen)
**Setup Time:** 15-20 minutes

---

## Quick Setup Steps

### 1. Create Widget Extension (2 min)
```
File → New → Target → Widget Extension
Name: MoodTrackerWidget
✅ Activate scheme when prompted
```

### 2. Enable App Groups (3 min)
```
Main App Target:
  Signing & Capabilities → + Capability → App Groups
  Add: group.com.dailymoodtracker.app ✅

Widget Target:
  Signing & Capabilities → + Capability → App Groups
  Add: group.com.dailymoodtracker.app ✅
```

### 3. Add Files (3 min)
```
Widget Target:
  ✅ MoodTrackerWidget.swift (widget only)
  ✅ Info.plist (widget only)

Both Targets:
  ✅ SharedModels.swift (main + widget)

Main App Only:
  ✅ DataManager_Updated.swift → rename to DataManager.swift
```

### 4. Add Assets (3 min)
```
MoodTrackerWidget/Assets.xcassets:
  ✅ HappyEmoji (PNG)
  ✅ NeutralEmoji (PNG)
  ✅ SadEmoji (PNG)
  ✅ AngryEmoji (PNG)
  ✅ SleepyEmoji (PNG)
```

### 5. Build & Test (4 min)
```
Clean: Product → Clean Build Folder
Build Widget: Scheme = MoodTrackerWidget, Cmd+B
Run App: Scheme = DailyMoodTracker, Cmd+R
Add Widget: Long-press home screen → + → Mood Tracker
```

---

## Required File Names (Case-Sensitive!)

### Assets
- `HappyEmoji` (not happyemoji or Happy_Emoji)
- `NeutralEmoji`
- `SadEmoji`
- `AngryEmoji`
- `SleepyEmoji`

### Code Files
- `MoodTrackerWidget.swift`
- `SharedModels.swift`
- `DataManager.swift` (updated version)
- `Info.plist`

---

## Common Errors & Quick Fixes

### "No data" in widget
```
✅ Check: App Groups enabled on BOTH targets
✅ Check: Same group ID on both
✅ Check: DataManager uses App Groups
```

### Build error: "Cannot find SharedMoodEntry"
```
✅ Check: SharedModels.swift in BOTH targets
   File Inspector → Target Membership:
   ✅ DailyMoodTracker
   ✅ MoodTrackerWidget
```

### Widget not updating
```
✅ Check: DataManager calls WidgetCenter.shared.reloadAllTimelines()
✅ Check: Using updated DataManager (has import WidgetKit)
✅ Try: Remove and re-add widget
```

### Images not showing
```
✅ Check: Images in widget's Assets.xcassets (not main app)
✅ Check: Exact names (case-sensitive)
✅ Check: PNG format with transparency
```

---

## Key Code Locations

### App Group ID
```swift
// In both MoodTrackerWidget.swift and DataManager.swift
let appGroupID = "group.com.dailymoodtracker.app"
```

### Reload Widgets
```swift
// In DataManager.swift saveEntries() method
WidgetCenter.shared.reloadAllTimelines()
```

### Widget Update Frequency
```swift
// In MoodTrackerWidget.swift getTimeline() method
let nextUpdate = Calendar.current.date(
    byAdding: .minute,
    value: 15, // ← Change this number
    to: Date()
)!
```

---

## Widget Sizes Reference

| Size | Name | Dimensions | Shows |
|------|------|------------|-------|
| Small | systemSmall | 2×2 | Dominant mood + count |
| Medium | systemMedium | 4×2 | Mood + 3 recent entries |
| Large | systemLarge | 4×4 | Full timeline with notes |
| Circular | accessoryCircular | Circle | Lock screen emoji + count |
| Rectangular | accessoryRectangular | Rectangle | Lock screen mood + count |
| Inline | accessoryInline | Text | Lock screen compact |

---

## Color Codes

### Mood Gradients

**Happy:** `#FFD93D → #FFAA80` (Yellow to Peach)
**Neutral:** `#A8D8EA → #6BA3BE` (Light to Medium Blue)
**Sad:** `#C8B6E2 → #9B7EBD` (Light to Medium Purple)
**Angry:** `#FF6B6B → #E63946` (Bright to Deep Red)
**Sleepy:** `#F4E4C1 → #C9C9C9` (Cream to Gray)

---

## Xcode Shortcuts

**Clean Build:** `Cmd + Shift + K`
**Build:** `Cmd + B`
**Run:** `Cmd + R`
**Stop:** `Cmd + .`
**Show Navigator:** `Cmd + 1`
**Show File Inspector:** `Cmd + Option + 1`

---

## Testing Commands

### On Device (iPhone)

**Add Home Screen Widget:**
1. Long-press home screen
2. Tap + (top-left)
3. Search "Mood"
4. Tap "Add Widget"

**Add Lock Screen Widget (iOS 16+):**
1. Long-press lock screen
2. Tap "Customize"
3. Tap below time
4. Tap +, find "Mood Tracker"

**Force Widget Refresh:**
- Remove widget and re-add
- Or restart iPhone

---

## Verification Commands

### Check App Group Setup
```swift
// Add to app launch or button action
let isConfigured = dataManager.verifyAppGroupConfiguration()
print("App Group configured: \(isConfigured)")
// Should print: "✅ App Group is properly configured"
```

### Check Shared Data
```swift
// In Xcode console, look for:
"✅ Successfully saved X entries"
"🔄 Reloading all widget timelines..."
"✅ Widget timelines reloaded"
```

---

## File Structure Checklist

```
DailyMoodTracker/
├── DailyMoodTracker/
│   ├── Services/
│   │   └── DataManager.swift ← UPDATED VERSION
│   └── [other app files]
│
└── MoodTrackerWidget/
    ├── MoodTrackerWidget.swift ← NEW
    ├── Models/
    │   └── SharedModels.swift ← NEW (both targets)
    ├── Assets.xcassets/
    │   ├── HappyEmoji ← NEW
    │   ├── NeutralEmoji ← NEW
    │   ├── SadEmoji ← NEW
    │   ├── AngryEmoji ← NEW
    │   └── SleepyEmoji ← NEW
    └── Info.plist ← REPLACED
```

---

## Target Membership Quick Check

### DailyMoodTracker Target
- ✅ All main app files
- ✅ SharedModels.swift
- ✅ DataManager.swift (updated)
- ❌ MoodTrackerWidget.swift
- ❌ Widget assets

### MoodTrackerWidget Target
- ✅ MoodTrackerWidget.swift
- ✅ SharedModels.swift
- ✅ Widget assets
- ✅ Info.plist
- ❌ Main app files

---

## Console Debug Messages

### Success Messages (Good!)
```
✅ App Group is properly configured
✅ Successfully loaded X entries
✅ Successfully saved X entries
✅ Widget timelines reloaded
```

### Warning Messages (Check these)
```
⚠️ WARNING: Could not initialize App Group UserDefaults!
⚠️ No data found in shared UserDefaults
⚠️ synchronize() returned false
```

### Error Messages (Fix immediately)
```
❌ Shared UserDefaults not available
❌ Error loading entries: [error]
❌ Verification failed: [error]
```

---

## Documentation Quick Links

**Full Setup Guide:** `WIDGET_SETUP_GUIDE.md`
**Step-by-Step Checklist:** `WIDGET_CHECKLIST.md`
**Visual Design Guide:** `WIDGET_VISUALS.md`
**Getting Started:** `START_HERE.md`
**Complete Reference:** `README.md`

---

## Emergency Troubleshooting

### Nothing works? Try this sequence:

1. **Clean everything**
   ```
   Product → Clean Build Folder (Cmd + Shift + K)
   Close Xcode
   Delete DerivedData folder
   Reopen project
   ```

2. **Verify App Groups**
   ```
   Both targets must have:
   - App Groups capability
   - Same group ID
   - Checkbox checked ✅
   ```

3. **Rebuild from scratch**
   ```
   Delete widget target
   Follow WIDGET_SETUP_GUIDE.md step by step
   Don't skip any steps
   ```

4. **Check file targets**
   ```
   Select each file
   Check Target Membership (right sidebar)
   Ensure correct targets are checked
   ```

5. **Test on real device**
   ```
   Widgets don't work properly in simulator
   Must test on physical iPhone
   ```

---

## Support Checklist

Before asking for help, verify:

- [ ] App Groups enabled on BOTH targets
- [ ] Same App Group ID on both
- [ ] All 5 emoji assets added to widget
- [ ] DataManager is updated version
- [ ] SharedModels.swift in both targets
- [ ] Clean build performed
- [ ] Testing on real iPhone (not simulator)
- [ ] Followed WIDGET_SETUP_GUIDE.md exactly

---

## Success Indicators

You're done when:

✅ Widget appears in widget gallery
✅ Widget shows current mood data
✅ Widget updates after logging mood
✅ All sizes work correctly
✅ No console errors
✅ Beautiful gradients display

---

## Customization Quick Tips

### Change Update Frequency
```swift
// MoodTrackerWidget.swift, line ~42
value: 15, // Change to 5 for 5 minutes, 30 for 30 minutes
```

### Change Gradient Colors
```swift
// SharedModels.swift, widgetGradient property
case .happy:
    return [Color(hex: "YOUR_COLOR_1"), Color(hex: "YOUR_COLOR_2")]
```

### Change Widget Display Name
```swift
// MoodTrackerWidget.swift, line ~261
.configurationDisplayName("Your New Name")
.description("Your new description")
```

---

**Keep this card handy during setup!** 📌

For detailed instructions, see `WIDGET_SETUP_GUIDE.md`

---

*Version: 1.0 • Last Updated: November 2025*
