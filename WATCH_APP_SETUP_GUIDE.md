# Apple Watch App Setup Guide

This guide will help you add the Watch App target to your Xcode project.

## Prerequisites
- Xcode 15.0 or later
- watchOS 10.0 or later
- Apple Watch paired with your iPhone

## Files Already Created

I've created all the necessary Watch App source files:

```
MoodTrackerWatch Watch App/
├── MoodTrackerWatchApp.swift          # Watch App entry point
├── ContentView.swift                   # Main Watch UI with mood grid
├── WatchDataManager.swift              # Data manager for Watch
└── MoodTrackerWatch Watch App.entitlements  # App Group entitlements
```

## Step-by-Step Instructions

### Step 1: Add Watch App Target in Xcode

1. Open `DailyMoodTracker.xcodeproj` in Xcode
2. In the Project Navigator (left sidebar), click on the **DailyMoodTracker** project (blue icon at the top)
3. Click the **+** button at the bottom of the targets list
4. Select **watchOS** → **App** → **Watch App for iOS App**
5. Click **Next**

### Step 2: Configure Watch Target Settings

Fill in the following details:

- **Product Name**: `MoodTrackerWatch Watch App`
- **Team**: Select your Apple Developer Team
- **Organization Identifier**: `com.aibymm`
- **Bundle Identifier**: Should auto-fill as `com.aibymm.moodflex.watchkitapp`
- **Language**: Swift
- **User Interface**: SwiftUI
- **Include Notification Scene**: ☑️ (Check this)
- **Host Application**: DailyMoodTracker

Click **Finish**.

### Step 3: Replace Auto-Generated Files

Xcode will create some boilerplate files. Replace them with our pre-made files:

1. In the Project Navigator, expand **MoodTrackerWatch Watch App**
2. **Delete** these auto-generated files (Move to Trash):
   - `MoodTrackerWatch_Watch_AppApp.swift` (or similar name)
   - `ContentView.swift`
   - `Assets.xcassets` (we'll use shared assets)

3. **Add** our pre-made files:
   - Right-click on **MoodTrackerWatch Watch App** folder
   - Select **Add Files to "DailyMoodTracker"...**
   - Navigate to `/MoodTrackerWatch Watch App/` folder
   - Select these files:
     - `MoodTrackerWatchApp.swift`
     - `ContentView.swift`
     - `WatchDataManager.swift`
   - Make sure **"MoodTrackerWatch Watch App" target** is checked
   - Click **Add**

### Step 4: Share Model Files with Watch Target

The Watch app needs access to the existing `MoodType` and `SharedMoodEntry` models:

1. In Project Navigator, find these files in **DailyMoodTracker/Models/**:
   - `SharedModels.swift` (contains MoodType and SharedMoodEntry)

2. For **each file**, do the following:
   - Click on the file
   - Open the **File Inspector** (right sidebar, first tab)
   - Under **Target Membership**, check the box for **MoodTrackerWatch Watch App**

### Step 5: Configure App Groups

1. Select the **MoodTrackerWatch Watch App** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Search for and add **App Groups**
5. Click **+** under App Groups
6. Enter: `group.com.aibymm.moodflex`
7. Click **OK**

**OR** if the App Group already exists:
- Just check the box next to `group.com.aibymm.moodflex`

### Step 6: Configure Entitlements

1. In Project Navigator, find `MoodTrackerWatch Watch App.entitlements`
2. Verify it contains:
   ```xml
   <key>com.apple.security.application-groups</key>
   <array>
       <string>group.com.aibymm.moodflex</string>
   </array>
   ```

### Step 7: Configure Watch App Assets (Optional)

If you want custom Watch app icons:

1. Select **Assets** in the Watch target
2. Add Watch App Icon sizes:
   - 38mm: 80x80
   - 40mm: 88x88
   - 44mm: 100x100
   - App Store: 1024x1024

For now, you can use placeholder icons or the default.

### Step 8: Build and Run

1. **Select** the Watch scheme:
   - At the top of Xcode, click the scheme dropdown
   - Select **MoodTrackerWatch Watch App**

2. **Select** your Watch Simulator or paired Watch:
   - Click the device dropdown next to the scheme
   - Choose either:
     - **Apple Watch Series 9 - 45mm** (Simulator)
     - Your paired **Apple Watch** (if connected)

3. Click **Run** (⌘R)

## Testing

### Test Data Sync:

1. **On iPhone**: Log a mood entry in the main app
2. **On Watch**: Open the Watch app
   - You should see the entry in "Today" section

3. **On Watch**: Tap a mood button to log from Watch
   - You should see confirmation alert
   - Check iPhone app to verify the entry appeared

4. **Test Notifications**:
   - Enable daily reminder in iPhone Settings
   - When notification appears on Watch, swipe down
   - You should see 5 mood action buttons
   - Tap one to log mood directly from notification

## Troubleshooting

### "App Group not found" error:
- Make sure you've added the App Group capability to **both**:
  - DailyMoodTracker (iOS) target
  - MoodTrackerWatch Watch App (watchOS) target
- Use the **exact same** App Group ID: `group.com.aibymm.moodflex`

### "Cannot find 'MoodType' in scope":
- Make sure `SharedModels.swift` has **both** targets checked in Target Membership

### Watch app doesn't show data:
- Check that both apps use the **same** App Group ID
- Verify the App Group is enabled in your Apple Developer account
- Try force quitting both apps and restarting

### Build errors:
- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Restart Xcode
- Make sure all file paths are correct

## Architecture Notes

### Data Flow:
1. **iPhone → Watch**: Watch reads from shared UserDefaults in App Group
2. **Watch → iPhone**: Watch writes to shared UserDefaults, iPhone detects changes
3. **Real-time sync**: Currently using App Group (passive sync)
4. **Future enhancement**: Add Watch Connectivity for active bidirectional sync

### Why App Group Instead of Watch Connectivity?
- **Simpler implementation**: Works offline without iPhone nearby
- **Reliable persistence**: Data survives app restarts
- **Battery efficient**: No active connection needed
- **Same pattern as widgets**: Already proven to work

### Future Enhancements:
- Add Watch Connectivity for instant sync when iPhone is nearby
- Add complications (small widgets on Watch face)
- Add Siri shortcuts for voice logging
- Add haptic feedback patterns for different moods

## Support

If you encounter any issues:
1. Check the console logs for errors (⌘⇧Y to show Console)
2. Verify App Group is properly configured in Apple Developer portal
3. Make sure your Apple Watch is running watchOS 10.0 or later

---

**Done!** Your Watch app should now be working. Users can log moods directly from their wrist! 🎉
