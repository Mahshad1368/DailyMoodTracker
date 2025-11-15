//
//  HomeView.swift
//  DailyMoodTracker
//
//  Main screen for logging mood entries - Redesigned with modern UI
//

import SwiftUI
import AVFoundation

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("userName") private var userName: String = "User"
    @AppStorage("darkModeEnabled") private var isDarkMode: Bool = true
    @State private var selectedMood: MoodType?
    @State private var note: String = ""
    @State private var showingToast = false
    @State private var justSaved = false
    @FocusState private var isNoteFieldFocused: Bool

    // Profile picture
    @State private var profilePictureData: Data? = UserDefaults.standard.data(forKey: "profilePicture")

    // Photo picker - Action sheet with camera OR gallery
    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var selectedPhotoData: Data?

    // Voice recording
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var recordedAudioData: Data?
    @State private var audioDuration: TimeInterval = 0
    @State private var recordingTimer: Timer?

    // Current date for time-based gradient
    @State private var currentDate = Date()

    // Flying emoji animation states
    @State private var isAnimatingMood = false
    @State private var flyingEmoji: String = ""
    @State private var emojiYOffset: CGFloat = 0
    @State private var emojiOpacity: Double = 0
    @State private var newEntryID: UUID?

    // Selected entry for detail view
    @State private var selectedEntry: MoodEntry?

    // Computed property for today's entries
    private var todayEntries: [MoodEntry] {
        dataManager.getEntriesToday()
    }

    // Dynamic theme colors
    private var theme: ThemeColors {
        isDarkMode ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic theme gradient background
                DarkThemeBackground(isDark: isDarkMode)

                VStack(spacing: 0) {
                    // Top Navigation Bar - Greeting + Smart Icon
                    HStack(alignment: .top, spacing: 16) {
                        // Personalized Greeting - Left side
                        VStack(alignment: .leading, spacing: 4) {
                            // Greeting with name
                            Text("\(currentDate.greeting), \(userName)!")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)

                            // Date
                            Text(currentDate.friendlyDateString)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(theme.textSecondary)
                        }

                        Spacer()

                        // Smart Icon: Settings gear OR Profile photo (top-right)
                        NavigationLink(destination: SettingsView()) {
                            if let profilePictureData = profilePictureData,
                               let uiImage = UIImage(data: profilePictureData) {
                                // User has profile photo - show it
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(theme.accent.opacity(0.5), lineWidth: 2)
                                    )
                                    .shadow(color: theme.accent.opacity(0.3), radius: 4, x: 0, y: 2)
                            } else {
                                // No profile photo - show settings gear
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(theme.textPrimary.opacity(0.9))
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 15)
                    .padding(.bottom, 25)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Main Glass Card (Prominent - Centered)
                        DarkThemeCard(padding: 28, isDark: isDarkMode, cornerRadius: 24) {
                            VStack(spacing: 25) {
                                // Question - BOLD AND CENTERED
                                Text("How are you feeling right now?")
                                    .font(.system(size: 26, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(theme.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 8)
                                    .padding(.bottom, 4)

                                // Mood Selection - 5 buttons in a row (flexible)
                                HStack(spacing: 8) {
                                    EnhancedMoodButton(
                                        mood: .happy,
                                        isSelected: selectedMood == .happy
                                    ) {
                                        selectedMood = .happy
                                    }

                                    EnhancedMoodButton(
                                        mood: .neutral,
                                        isSelected: selectedMood == .neutral
                                    ) {
                                        selectedMood = .neutral
                                    }

                                    EnhancedMoodButton(
                                        mood: .sad,
                                        isSelected: selectedMood == .sad
                                    ) {
                                        selectedMood = .sad
                                    }

                                    EnhancedMoodButton(
                                        mood: .angry,
                                        isSelected: selectedMood == .angry
                                    ) {
                                        selectedMood = .angry
                                    }

                                    EnhancedMoodButton(
                                        mood: .sleepy,
                                        isSelected: selectedMood == .sleepy
                                    ) {
                                        selectedMood = .sleepy
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 95)

                                // Note Input Field
                                VStack(spacing: 12) {
                                    TextField("Add a note...", text: $note, axis: .vertical)
                                        .textFieldStyle(.plain)
                                        .foregroundColor(theme.textPrimary)
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill((isDarkMode ? Color.black : Color.white).opacity(0.2))
                                        )
                                        .lineLimit(3...5)
                                        .focused($isNoteFieldFocused)

                                    // Photo and Voice Buttons
                                    attachmentButtonsView

                                    // Photo Preview (if photo selected)
                                    if let photoData = selectedPhotoData, let uiImage = UIImage(data: photoData) {
                                        HStack(spacing: 12) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Photo attached")
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(theme.textPrimary)

                                                Text("\(photoData.count / 1024) KB")
                                                    .font(.system(.caption, design: .rounded))
                                                    .foregroundColor(theme.textSecondary)
                                            }

                                            Spacer()

                                            Button(action: { selectedPhotoData = nil }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(theme.textSecondary)
                                            }
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill((isDarkMode ? Color.black : Color.white).opacity(0.2))
                                        )
                                    }
                                }

                                // Save Mood Button
                                GlowingButton(
                                    title: justSaved ? "✓ Saved!" : "Save Mood",
                                    action: logMood,
                                    isEnabled: selectedMood != nil,
                                    colors: [Color(hex: "b98fa0"), Color(hex: "897691")]
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Today's Timeline Section - MOVED UP, MORE PROMINENT
                        if !todayEntries.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                // Subtle divider
                                Divider()
                                    .background(theme.textSecondary.opacity(0.3))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 4)

                                Text("Today's Timeline")
                                    .font(.system(size: 22, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(theme.textPrimary)
                                    .padding(.horizontal, 25)

                                VStack(spacing: 12) {
                                    ForEach(todayEntries) { entry in
                                        TimelineEntryCard(
                                            entry: entry,
                                            isHighlighted: newEntryID == entry.id,
                                            isDark: isDarkMode
                                        )
                                        .padding(.horizontal, 20)
                                        .onTapGesture {
                                            selectedEntry = entry
                                        }
                                    }
                                }
                            }
                            .padding(.top, 0)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .scrollDismissesKeyboard(.interactively)

                // Flying emoji overlay
                if isAnimatingMood {
                    VStack {
                        Text(flyingEmoji)
                            .font(.system(size: 60))
                            .offset(y: emojiYOffset)
                            .opacity(emojiOpacity)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

                        Spacer()
                    }
                    .allowsHitTesting(false)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isNoteFieldFocused = false
                    }
                }
            }
            .sheet(item: $selectedEntry) { entry in
                // Show entry detail sheet (same as calendar day view)
                EntryDetailSheet(
                    entry: entry,
                    isDark: isDarkMode,
                    onDelete: {
                        dataManager.deleteEntry(entry)
                        selectedEntry = nil
                    }
                )
                .environmentObject(dataManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .toast(
                isShowing: $showingToast,
                message: "Mood saved!",
                icon: "checkmark.circle.fill",
                duration: 2.0
            )
            .confirmationDialog("Add Photo", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
                Button("📷 Take Photo") {
                    showingCamera = true
                }
                Button("🖼️ Choose from Gallery") {
                    showingGallery = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(selectedImageData: $selectedPhotoData)
            }
            .sheet(isPresented: $showingGallery) {
                PhotoPickerView(selectedImageData: $selectedPhotoData)
            }
            }
            .onAppear {
                // Update current date when view appears
                currentDate = Date()
                setupAudioSession()
                // Refresh profile picture in case it was updated in Settings
                profilePictureData = UserDefaults.standard.data(forKey: "profilePicture")
            }
        }
    }

    // MARK: - Subviews

    private var attachmentButtonsView: some View {
        HStack(spacing: 15) {
            photoPickerButton
            voiceRecordingButton
        }
    }

    private var photoPickerButton: some View {
        Button(action: {
            showingPhotoOptions = true
        }) {
            Image(systemName: selectedPhotoData != nil ? "camera.fill" : "camera")
                .font(.system(size: 22))
                .foregroundColor(selectedPhotoData != nil ? theme.accent : theme.textSecondary)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(selectedPhotoData != nil ? theme.accent.opacity(0.2) : (isDarkMode ? Color.black : Color.white).opacity(0.2))
                )
        }
    }

    private var voiceRecordingButton: some View {
        Button(action: toggleRecording) {
            ZStack {
                Image(systemName: voiceMicIcon)
                    .font(.system(size: 22))
                    .foregroundColor(voiceMicColor)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(voiceButtonBackground)
                    )

                // Show recording duration as overlay badge when recording
                if isRecording {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(formatDuration(audioDuration))
                                .font(.system(size: 9, design: .rounded).monospacedDigit())
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.red)
                                )
                                .offset(x: 8, y: 8)
                        }
                    }
                    .frame(width: 50, height: 50)
                }
            }
        }
    }

    // Voice button computed properties
    private var voiceMicIcon: String {
        if isRecording {
            return "mic.fill"
        } else if recordedAudioData != nil {
            return "mic.fill"
        } else {
            return "mic"
        }
    }

    private var voiceMicColor: Color {
        if isRecording {
            return .red
        } else if recordedAudioData != nil {
            return theme.accent
        } else {
            return theme.textSecondary
        }
    }

    private var voiceButtonText: String {
        if isRecording {
            return formatDuration(audioDuration)
        } else if recordedAudioData != nil {
            return "Audio Added"
        } else {
            return "Add Voice"
        }
    }

    private var voiceTextColor: Color {
        if isRecording {
            return .red
        } else if recordedAudioData != nil {
            return theme.accent
        } else {
            return theme.textSecondary
        }
    }

    private var voiceButtonBackground: Color {
        if isRecording {
            return Color.red.opacity(0.2)
        } else if recordedAudioData != nil {
            return theme.accent.opacity(0.2)
        } else {
            return (isDarkMode ? Color.black : Color.white).opacity(0.2)
        }
    }

    // MARK: - Functions

    private func logMood() {
        guard let mood = selectedMood else { return }

        // Automatically stop recording if still recording
        if isRecording {
            stopRecording()
        }

        // Dismiss keyboard
        isNoteFieldFocused = false

        // CAPTURE VALUES IMMEDIATELY to avoid race conditions
        let capturedMood = mood
        let capturedNote = note
        let capturedPhotoData = selectedPhotoData
        let capturedAudioData = recordedAudioData
        let capturedAudioDuration = audioDuration

        // Haptic feedback - success vibration
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Show button animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            justSaved = true
        }

        // Show toast
        showingToast = true

        // START FLYING EMOJI ANIMATION
        flyingEmoji = capturedMood.emoji
        emojiOpacity = 1.0
        emojiYOffset = 0 // Start at button position
        isAnimatingMood = true

        // Animate emoji dropping down with easeIn (gravity effect)
        withAnimation(.easeIn(duration: 0.7)) {
            emojiYOffset = 400 // Drop distance (adjust based on screen)
        }

        // Fade out emoji as it reaches destination
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                emojiOpacity = 0
            }
        }

        // Add entry to data AFTER animation starts (so it appears when emoji arrives)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Add the entry with captured values
            dataManager.addEntry(
                mood: capturedMood,
                note: capturedNote,
                photoData: capturedPhotoData,
                audioData: capturedAudioData,
                audioDuration: capturedAudioData != nil ? capturedAudioDuration : nil
            )

            // Get the new entry ID for highlight - with safety check
            DispatchQueue.main.async {
                if let newEntry = dataManager.getEntriesToday().first {
                    newEntryID = newEntry.id

                    // Clear highlight after brief moment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            newEntryID = nil
                        }
                    }
                }
            }

            // Clean up animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimatingMood = false
                flyingEmoji = ""
                emojiYOffset = 0
            }
        }

        // Reset button text after 1 second, then clear form
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                justSaved = false
            }

            // Clear form after button animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                selectedMood = nil
                note = ""
                selectedPhotoData = nil
                recordedAudioData = nil
                audioDuration = 0
            }
        }
    }

    // MARK: - Photo Handling

    // Photo selection is handled by onChange(of: selectedPhotoItem)

    // MARK: - Voice Recording

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        // Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            if allowed {
                DispatchQueue.main.async {
                    self.performStartRecording()
                }
            } else {
                print("Microphone permission denied")
            }
        }
    }

    private func performStartRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()

            isRecording = true
            audioDuration = 0

            // Start timer to update duration
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.audioDuration += 0.1
            }
        } catch {
            print("Could not start recording: \(error)")
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil

        // Load recorded audio data
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        recordedAudioData = try? Data(contentsOf: audioFilename)
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Timeline Entry Card

struct TimelineEntryCard: View {
    let entry: MoodEntry
    let isHighlighted: Bool
    let isDark: Bool

    @State private var scale: CGFloat = 1.0

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Time indicator with emoji
            VStack(spacing: 4) {
                Text(entry.date.timeOfDay.emoji)
                    .font(.system(size: 20))

                Text(entry.formattedTime)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(theme.textSecondary)
            }
            .frame(width: 50)

            // Mood content card
            VStack(alignment: .leading, spacing: 10) {
                // Mood header
                HStack(spacing: 10) {
                    Text(entry.mood.emoji)
                        .font(.system(size: 40))

                    Text(entry.mood.name)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)

                    Spacer()
                }

                // Note
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(theme.textSecondary)
                        .lineSpacing(3)
                        .lineLimit(2)
                }

                // Photo thumbnail (if available)
                if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Attachments indicator (voice only, photo is shown above)
                HStack(spacing: 12) {
                    if entry.audioData != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 12))
                            Text("Voice")
                                .font(.system(.caption2, design: .rounded))
                        }
                        .foregroundColor(theme.accent)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                HStack(spacing: 0) {
                    // Colored left accent
                    Rectangle()
                        .fill(entry.mood.color)
                        .frame(width: 3)

                    Color.white.opacity(isHighlighted ? 0.15 : 0.08)
                }
            )
            .cornerRadius(20)
            .shadow(
                color: isHighlighted ? entry.mood.color.opacity(0.4) : Color.black.opacity(0.2),
                radius: isHighlighted ? 12 : 8,
                x: 0,
                y: isHighlighted ? 6 : 4
            )
        }
        .scaleEffect(scale)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: scale)
        .onAppear {
            // Pop-in animation for new entries
            if isHighlighted {
                scale = 0.3
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
        }
        .onChange(of: isHighlighted) { highlighted in
            if highlighted {
                // Elastic bounce effect: scale up, overshoot, settle
                scale = 0.3
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
        }
    }
}

// MARK: - Entry Detail Sheet
struct EntryDetailSheet: View {
    let entry: MoodEntry
    let isDark: Bool
    let onDelete: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayingAudio = false
    @State private var showingPhoto = false

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        ZStack {
            // Background
            (isDark ? Color.darkTheme.bgDarker : Color.lightTheme.bgLight)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)

                        Text(formattedTime)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(theme.textSecondary)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.textSecondary)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        // Mood card
                        HStack(spacing: 15) {
                            Text(entry.mood.emoji)
                                .font(.system(size: 60))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.mood.name)
                                    .font(.system(.title, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(theme.textPrimary)
                            }

                            Spacer()
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(entry.mood.color.opacity(0.15))
                        )

                        // Note
                        if !entry.note.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Note")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.textSecondary)
                                    .textCase(.uppercase)

                                Text(entry.note)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(theme.textPrimary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill((isDark ? Color.white : Color.black).opacity(0.05))
                            )
                        }

                        // Photo
                        if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Photo")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.textSecondary)
                                    .textCase(.uppercase)

                                Button(action: { showingPhoto = true }) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }

                        // Voice recording
                        if entry.audioData != nil {
                            Button(action: toggleAudio) {
                                HStack(spacing: 12) {
                                    Image(systemName: isPlayingAudio ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(theme.accent)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Voice Recording")
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(theme.textPrimary)

                                        if let duration = entry.audioDuration {
                                            Text(formatDuration(duration))
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(theme.textSecondary)
                                        }
                                    }

                                    Spacer()
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(theme.accent.opacity(0.1))
                                )
                            }
                        }

                        // Delete button
                        Button(action: { showingDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Entry")
                            }
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showingPhoto) {
            if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { showingPhoto = false }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }

                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()

                        Spacer()
                    }
                }
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this mood entry?")
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: entry.date)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    private func toggleAudio() {
        guard let audioData = entry.audioData else { return }

        if isPlayingAudio {
            audioPlayer?.stop()
            audioPlayer = nil
            isPlayingAudio = false
        } else {
            do {
                audioPlayer = try AVAudioPlayer(data: audioData)
                audioPlayer?.play()
                isPlayingAudio = true

                DispatchQueue.main.asyncAfter(deadline: .now() + (entry.audioDuration ?? 0)) {
                    isPlayingAudio = false
                }
            } catch {
                print("Error playing audio: \(error)")
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    HomeView()
        .environmentObject(DataManager())
}
