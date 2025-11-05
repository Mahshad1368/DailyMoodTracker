# Daily Mood Tracker 📱🎨

An iOS mood tracking app with **dynamic app icons** that change based on your daily mood!

![iOS 16+](https://img.shields.io/badge/iOS-16%2B-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-orange)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Features

### Core Functionality
- **5 Mood Types**: Happy 😊, Neutral 😐, Sad 😔, Angry 😡, Sleepy 😴
- **Multiple Entries Per Day**: Log your mood as many times as you want
- **Timeline View**: See all your moods for today with timestamps
- **Calendar History**: Browse past moods with visual colored indicators
- **Local Data Persistence**: All data stored securely on device

### 🎨 Dynamic App Icons (Unique Feature!)
- **Auto-Changing Icons**: App icon changes based on your dominant daily mood
- **5 Gradient Designs**: Beautiful gradient backgrounds for each mood
- **Real-Time Updates**: Icon updates immediately when you log moods
- **Persistent**: Icon remains until your dominant mood changes

---

## 📸 Screenshots

| Home Screen | Calendar | Dynamic Icons |
|-------------|----------|---------------|
| Timeline of today's moods | Monthly mood calendar | Icon changes with mood |

---

## 🚀 Getting Started

### Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/DailyMoodTracker.git
   cd DailyMoodTracker
   ```

2. **Open in Xcode**
   ```bash
   open DailyMoodTracker.xcodeproj
   ```

3. **Build and Run**
   - Connect your iPhone or use Simulator
   - Press ⌘R to build and run

---

## 🎨 Dynamic Icons Setup

The app includes test icons with gradients. To customize:

1. **Generate custom icons** using AI (DALL-E, Midjourney, etc.)
   - See `AI_ICON_PROMPTS.md` for ready-to-use prompts
   - Or use `QUICK_START_AI_ICONS.md` for step-by-step guide

2. **Run the icon generator**
   ```bash
   python3 create_test_icons.py
   ```

3. **Or use the resize script**
   ```bash
   ./resize_icons.sh
   ```

Full documentation: `DYNAMIC_APP_ICONS_GUIDE.md`

---

## 📁 Project Structure

```
DailyMoodTracker/
├── DailyMoodTracker/
│   ├── Models/
│   │   ├── MoodType.swift          # Mood enum with colors
│   │   └── MoodEntry.swift         # Data model
│   ├── Views/
│   │   ├── HomeView.swift          # Main screen with timeline
│   │   └── HistoryView.swift       # Calendar view
│   ├── Services/
│   │   ├── DataManager.swift       # UserDefaults persistence
│   │   └── IconManager.swift       # Dynamic icon switching
│   ├── Assets.xcassets/
│   └── Info.plist                  # Alternate icon config
├── Documentation/
│   ├── AI_ICON_PROMPTS.md         # AI generation prompts
│   ├── DYNAMIC_APP_ICONS_GUIDE.md # Complete icon guide
│   └── QUICK_START_AI_ICONS.md    # Quick start guide
└── Scripts/
    ├── create_test_icons.py       # Generate test icons
    └── resize_icons.sh            # Resize icon script
```

---

## 🎯 How Dynamic Icons Work

The app calculates your **dominant mood** (most frequently logged) for the current day:

```swift
// IconManager.swift
func updateIconForDominantMood(entries: [MoodEntry]) {
    let todayEntries = entries.filter { isToday($0.date) }
    let dominantMood = calculateMostFrequent(todayEntries)
    setIcon(forMood: dominantMood)
}
```

Icon updates automatically when you:
- ✅ Log a new mood entry
- ✅ Delete an existing entry

---

## 🎨 Icon Colors

| Mood | Gradient | Hex Colors |
|------|----------|------------|
| Happy 😊 | Yellow → Peach | `#FFD93D` → `#FFAA80` |
| Neutral 😐 | Light Blue → Sky Blue | `#A8D8EA` → `#6BA3BE` |
| Sad 😔 | Lavender → Purple | `#C8B6E2` → `#9B7EBD` |
| Angry 😡 | Coral → Red | `#FF6B6B` → `#E63946` |
| Sleepy 😴 | Beige → Gray | `#F4E4C1` → `#C9C9C9` |

---

## 🛠️ Tech Stack

- **Framework**: SwiftUI
- **Architecture**: MVVM with ObservableObject
- **Persistence**: UserDefaults (with optional Firebase support)
- **iOS APIs**:
  - UIApplication.setAlternateIconName
  - @Published property wrappers
  - SwiftUI Calendar views
  - FocusState for keyboard management

---

## 📚 Documentation

- **`DYNAMIC_APP_ICONS_GUIDE.md`** - Complete guide to dynamic icons
- **`AI_ICON_PROMPTS.md`** - AI prompts for generating custom icons
- **`QUICK_START_AI_ICONS.md`** - 10-minute setup guide
- **`FIREBASE_SETUP.md`** - Optional cloud backend setup
- **`FIREBASE_SWIFT_CODE.md`** - Firebase integration code

---

## 🐛 Troubleshooting

### Icons Not Changing?
- Must test on **real device** (not simulator)
- Check Xcode console for debug logs
- Verify icon files are in project root

### Data Not Persisting?
- Check UserDefaults is not full
- Verify MoodType uses string raw values (not emojis)
- Look for console error messages

### Build Errors?
- Clean build folder: ⌘⇧K
- Check iOS deployment target is 16.0+
- Verify all files are added to target

---

## 🚀 Future Enhancements

- [ ] Cloud sync with Firebase
- [ ] Mood analytics and insights
- [ ] Streak tracking
- [ ] Reminders and notifications
- [ ] Mood notes with photos
- [ ] Export data to CSV/PDF
- [ ] Dark mode support
- [ ] Widget support
- [ ] Apple Watch companion app

---

## 📄 License

MIT License - feel free to use this project for learning or building your own mood tracker!

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📧 Contact

Built with [Claude Code](https://claude.com/claude-code)

---

## 🙏 Acknowledgments

- Icons generated with Python PIL/Pillow
- Design inspiration from iOS Health app
- Gradient colors from [UIGradients](https://uigradients.com)

---

⭐ Star this repo if you found it helpful!

Made with ❤️ and SwiftUI
