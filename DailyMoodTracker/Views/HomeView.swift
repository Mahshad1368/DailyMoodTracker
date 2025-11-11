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
    @AppStorage("showNotesField") private var showNotesField: Bool = true
    @AppStorage("requireNote") private var requireNote: Bool = false
    @State private var selectedMood: MoodType?
    @State private var note: String = ""
    @State private var showingToast = false
    @State private var justSaved = false
    @FocusState private var isNoteFieldFocused: Bool

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

    // Computed property to check if save button should be enabled
    private var canSaveMood: Bool {
        guard selectedMood != nil else { return false }

        // If notes are shown and required, check if note is not empty
        if showNotesField && requireNote {
            return !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        return true
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark theme gradient background
                DarkThemeBackground()

                VStack(spacing: 0) {
                    // Top Navigation Bar - Settings only
                    HStack {
                        Spacer()

                        // Settings Icon
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color.darkTheme.textPrimary.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Personalized Greeting
                        VStack(spacing: 6) {
                            Text("\(currentDate.greeting), \(userName)!")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color.darkTheme.textPrimary)

                            Text(currentDate.friendlyDateString)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Color.darkTheme.textSecondary)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                        // Main Glass Card
                        DarkThemeCard(padding: 25) {
                            VStack(spacing: 25) {
                                // Question
                                Text("How are you feeling right now?")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.darkTheme.textPrimary)
                                    .multilineTextAlignment(.center)

                                // Mood Selection - 5 buttons in a row
                                HStack(spacing: 10) {
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

                                // Note Input Field (only show if enabled in settings)
                                if showNotesField {
                                    VStack(spacing: 12) {
                                        TextField("Add a note...", text: $note, axis: .vertical)
                                            .textFieldStyle(.plain)
                                            .foregroundColor(Color.darkTheme.textPrimary)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.black.opacity(0.2))
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
                                                    .foregroundColor(Color.darkTheme.textPrimary)

                                                Text("\(photoData.count / 1024) KB")
                                                    .font(.system(.caption, design: .rounded))
                                                    .foregroundColor(Color.darkTheme.textSecondary)
                                            }

                                            Spacer()

                                            Button(action: { selectedPhotoData = nil }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(Color.darkTheme.textSecondary)
                                            }
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.2))
                                        )
                                    }
                                }
                                }

                                // Save Mood Button
                                GlowingButton(
                                    title: justSaved ? "✓ Saved!" : "Save Mood",
                                    action: logMood,
                                    isEnabled: canSaveMood,
                                    colors: [Color(hex: "FFD93D"), Color(hex: "FFA500")]
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Today's Timeline Section
                        if !todayEntries.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Today's Timeline")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.darkTheme.textPrimary)
                                    .padding(.horizontal, 25)

                                VStack(spacing: 12) {
                                    ForEach(todayEntries) { entry in
                                        TimelineEntryCard(
                                            entry: entry,
                                            isHighlighted: newEntryID == entry.id
                                        )
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                            .padding(.top, 10)
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
            HStack(spacing: 8) {
                Image(systemName: selectedPhotoData != nil ? "photo.fill" : "photo")
                    .font(.system(size: 20))
                    .foregroundColor(selectedPhotoData != nil ? Color.darkTheme.accent : Color.darkTheme.textSecondary)

                Text(selectedPhotoData != nil ? "Photo Added" : "Add Photo")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(selectedPhotoData != nil ? Color.darkTheme.accent : Color.darkTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedPhotoData != nil ? Color.darkTheme.accent.opacity(0.2) : Color.black.opacity(0.2))
            )
        }
    }

    private var voiceRecordingButton: some View {
        Button(action: toggleRecording) {
            HStack(spacing: 8) {
                Image(systemName: voiceMicIcon)
                    .font(.system(size: 20))
                    .foregroundColor(voiceMicColor)

                Text(voiceButtonText)
                    .font(.system(.caption, design: .rounded).monospacedDigit())
                    .foregroundColor(voiceTextColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(voiceButtonBackground)
            )
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
            return Color.darkTheme.accent
        } else {
            return Color.darkTheme.textSecondary
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
            return Color.darkTheme.accent
        } else {
            return Color.darkTheme.textSecondary
        }
    }

    private var voiceButtonBackground: Color {
        if isRecording {
            return Color.red.opacity(0.2)
        } else if recordedAudioData != nil {
            return Color.darkTheme.accent.opacity(0.2)
        } else {
            return Color.black.opacity(0.2)
        }
    }

    // MARK: - Functions

    private func logMood() {
        guard let mood = selectedMood else { return }

        // Validate required note if enabled
        if showNotesField && requireNote && note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Show error - note is required but empty
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }

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

    @State private var scale: CGFloat = 1.0

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Time indicator with emoji
            VStack(spacing: 4) {
                Text(entry.date.timeOfDay.emoji)
                    .font(.system(size: 20))

                Text(entry.formattedTime)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color.darkTheme.textSecondary)
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
                        .foregroundColor(Color.darkTheme.textPrimary)

                    Spacer()
                }

                // Note
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Color.darkTheme.textSecondary)
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
                        .foregroundColor(Color.darkTheme.accent)
                    }

                    if entry.audioData != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 12))
                            Text("Voice")
                                .font(.system(.caption2, design: .rounded))
                        }
                        .foregroundColor(Color.darkTheme.accent)
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
