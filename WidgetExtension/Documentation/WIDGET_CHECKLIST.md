# ✅ Widget Installation Checklist

## Daily Mood Tracker - Widget Setup

**Print this page and check off items as you complete them!**

---

## Phase 1: Project Setup (5 minutes)

### Create Widget Extension
- [ ] Opened DailyMoodTracker project in Xcode
- [ ] Added new target: File → New → Target → Widget Extension
- [ ] Named it "MoodTrackerWidget"
- [ ] Unchecked "Include Configuration Intent"
- [ ] Clicked "Finish" and "Activate"

### Add Widget Files
- [ ] Deleted auto-generated MoodTrackerWidget.swift
- [ ] Added new MoodTrackerWidget.swift from package
- [ ] Created "Models" folder in widget extension
- [ ] Added SharedModels.swift to BOTH targets
- [ ] Replaced Info.plist with provided version

**Quick Test:** Build widget target (Cmd + B) → Should succeed ✅

---

## Phase 2: App Groups Configuration (3 minutes)

### Enable on Widget Target
- [ ] Selected "MoodTrackerWidget" target
- [ ] Opened "Signing & Capabilities" tab
- [ ] Clicked "+ Capability"
- [ ] Added "App Groups"
- [ ] Added group: `group.com.dailymoodtracker.app`
- [ ] Verified checkbox is checked ✅

### Enable on Main App Target
- [ ] Selected "DailyMoodTracker" target
- [ ] Opened "Signing & Capabilities" tab
- [ ] Clicked "+ Capability" (if not already there)
- [ ] Added "App Groups"
- [ ] Verified `group.com.dailymoodtracker.app` appears
- [ ] Verified checkbox is checked ✅

**Quick Test:** Both targets show App Groups with same ID ✅

---

## Phase 3: Assets Setup (3 minutes)

### Add Emoji Images
- [ ] Opened MoodTrackerWidget/Assets.xcassets
- [ ] Created "HappyEmoji" image set
- [ ] Added Happy emoji PNG file
- [ ] Created "NeutralEmoji" image set
- [ ] Added Neutral emoji PNG file
- [ ] Created "SadEmoji" image set
- [ ] Added Sad emoji PNG file
- [ ] Created "AngryEmoji" image set
- [ ] Added Angry emoji PNG file
- [ ] Created "SleepyEmoji" image set
- [ ] Added Sleepy emoji PNG file

**Quick Test:** All 5 image sets visible in Assets.xcassets ✅

---

## Phase 4: Update Main App (2 minutes)

### Replace DataManager
- [ ] Duplicated existing DataManager.swift (backup)
- [ ] Deleted original DataManager.swift
- [ ] Added DataManager_Updated.swift from package
- [ ] Renamed to "DataManager.swift"
- [ ] Verified it's in Services folder
- [ ] Verified it's only in "DailyMoodTracker" target

**Quick Test:** Build main app (Cmd + B) → Should succeed ✅

---

## Phase 5: Build & Deploy (3 minutes)

### Clean Build
- [ ] Product → Clean Build Folder
- [ ] Waited for completion (~5 seconds)

### Build Widget
- [ ] Selected "MoodTrackerWidget" scheme
- [ ] Selected physical iPhone as destination
- [ ] Built successfully (Cmd + B)

### Build & Run Main App
- [ ] Selected "DailyMoodTracker" scheme
- [ ] Built and ran on iPhone (Cmd + R)
- [ ] App launched successfully
- [ ] Logged a test mood

**Quick Test:** Mood saved successfully in app ✅

---

## Phase 6: Widget Testing (4 minutes)

### Add Home Screen Widget
- [ ] Long-pressed home screen
- [ ] Tapped "+" button
- [ ] Found "Mood Tracker" in widget gallery
- [ ] Added Small widget
- [ ] Added Medium widget
- [ ] Added Large widget
- [ ] All widgets display mood data

### Add Lock Screen Widget (iOS 16+)
- [ ] Long-pressed lock screen
- [ ] Tapped "Customize"
- [ ] Added Circular widget
- [ ] Added Rectangular widget
- [ ] Added Inline widget
- [ ] All lock screen widgets show data

**Quick Test:** All widgets show current mood ✅

---

## Phase 7: Functionality Verification

### Data Display
- [ ] Widget shows correct dominant mood
- [ ] Widget shows correct entry count
- [ ] Widget displays mood emoji
- [ ] Widget shows gradient background
- [ ] Timeline displays on Medium widget
- [ ] Full timeline on Large widget

### Real-Time Updates
- [ ] Opened main app
- [ ] Logged a new mood
- [ ] Closed app
- [ ] Checked widget within 1 minute
- [ ] Widget updated with new mood ✅

### Different Moods
- [ ] Tested with Happy mood → Yellow gradient
- [ ] Tested with Neutral mood → Blue gradient
- [ ] Tested with Sad mood → Purple gradient
- [ ] Tested with Angry mood → Red gradient
- [ ] Tested with Sleepy mood → Gray gradient

**Quick Test:** All moods display with correct colors ✅

---

## Phase 8: Edge Cases

### No Data State
- [ ] Deleted all moods in app
- [ ] Checked widget shows "No mood yet"
- [ ] Added new mood
- [ ] Widget updated correctly

### Multiple Entries
- [ ] Logged 3+ moods in one day
- [ ] Widget shows dominant (most common) mood
- [ ] Medium widget shows 3 recent moods
- [ ] Large widget shows all moods

### Different Times
- [ ] Tested morning mood logging
- [ ] Tested afternoon mood logging
- [ ] Tested evening mood logging
- [ ] Timestamps display correctly

**Quick Test:** All edge cases handled ✅

---

## Final Verification

### Visual Checks
- [ ] Small widget looks good
- [ ] Medium widget looks good
- [ ] Large widget looks good
- [ ] Lock screen widgets look good
- [ ] Gradients display smoothly
- [ ] Text is readable
- [ ] Images are crisp

### Performance Checks
- [ ] Widget doesn't drain battery excessively
- [ ] Updates happen promptly (within 15 min max)
- [ ] App opens when tapping widget
- [ ] No crashes or freezes

### Code Quality
- [ ] No build warnings
- [ ] No console errors
- [ ] Clean code structure
- [ ] Comments are clear

---

## Troubleshooting Checks

If something doesn't work, verify:

### App Groups
- [ ] Enabled on BOTH targets
- [ ] Exact same ID: `group.com.dailymoodtracker.app`
- [ ] Checkboxes are checked
- [ ] No typos in group name

### Assets
- [ ] All 5 emoji images added
- [ ] Names match exactly (case-sensitive)
- [ ] Images are PNG format
- [ ] In widget's Assets.xcassets (not main app's)

### DataManager
- [ ] Using updated version
- [ ] Has `import WidgetKit`
- [ ] Calls `WidgetCenter.shared.reloadAllTimelines()`
- [ ] Uses `UserDefaults(suiteName:)`

### Build
- [ ] Clean build folder done
- [ ] Widget target builds
- [ ] Main app builds
- [ ] Testing on real iPhone (not simulator)

---

## Success Criteria

✅ **All items checked?** Congratulations! Your widget is complete!

You should have:
- [x] Working home screen widgets (3 sizes)
- [x] Working lock screen widgets (3 types)
- [x] Real-time mood updates
- [x] Beautiful gradient backgrounds
- [x] Professional appearance
- [x] Happy users!

---

## Post-Installation

### Optional Enhancements
- [ ] Customize widget gradients
- [ ] Adjust update frequency
- [ ] Add widget animations
- [ ] Create app screenshots with widgets
- [ ] Update App Store listing

### Documentation
- [ ] Keep this checklist for reference
- [ ] Bookmark QUICK_REFERENCE.md
- [ ] Save WIDGET_SETUP_GUIDE.md
- [ ] Review WIDGET_VISUALS.md

---

## Time Tracking

**Started at:** _______:_______

**Completed at:** _______:_______

**Total time:** _______ minutes

**Expected: 15-20 minutes**

---

## Notes & Issues

Use this space to jot down any problems you encountered:

```
Problem:


Solution:


```

---

## Sign-Off

- [ ] All checkboxes completed
- [ ] All tests passed
- [ ] Widget fully functional
- [ ] Ready for users

**Completed by:** _______________________

**Date:** _______/_______/_______

---

🎉 **Congratulations! You've successfully added widgets to your app!**

---

*Version: 1.0*
*Last Updated: November 2025*
