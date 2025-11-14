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
                    VStack(spacing: 20) {

                        // Main Glass Card (Prominent - Centered)
                        DarkThemeCard(padding: 28, isDark: isDarkMode) {
                            VStack(spacing: 25) {
                                // Question
                                Text("How are you feeling right now?")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.textPrimary)
                                    .multilineTextAlignment(.center)

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
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
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
                                    colors: [Color(hex: "FFD93D"), Color(hex: "FFA500")]
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Today's Timeline Section (Less prominent)
                        if !todayEntries.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Timeline")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(theme.textSecondary)
                                    .padding(.horizontal, 25)

                                VStack(spacing: 12) {
                                    ForEach(todayEntries) { entry in
                                        TimelineEntryCard(
                                            entry: entry,
                                            isHighlighted: newEntryID == entry.id,
                                            isDark: isDarkMode
                                        )
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                            .padding(.top, 5)
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
                    RoundedRectangle(cornerRadius: 12)
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
                        RoundedRectangle(cornerRadius: 12)
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
                        .font(.system(size: 28))

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
                }

                // Attachments indicator
                HStack(spacing: 12) {
                    if entry.photoData != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 12))
                            Text("Photo")
                                .font(.system(.caption2, design: .rounded))
                        }
                        .foregroundColor(theme.accent)
                    }

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
            .cornerRadius(12)
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

#Preview {
    HomeView()
        .environmentObject(DataManager())
}
