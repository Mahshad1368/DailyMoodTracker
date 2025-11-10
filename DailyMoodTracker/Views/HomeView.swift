//
//  HomeView.swift
//  DailyMoodTracker
//
//  Main screen for logging mood entries - Redesigned with modern UI
//

import SwiftUI
import PhotosUI
import AVFoundation

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("userName") private var userName: String = "User"
    @State private var selectedMood: MoodType?
    @State private var note: String = ""
    @State private var showingSaveAlert = false
    @FocusState private var isNoteFieldFocused: Bool

    // Photo picker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    // Voice recording
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var recordedAudioData: Data?
    @State private var audioDuration: TimeInterval = 0
    @State private var recordingTimer: Timer?

    // Current date for time-based gradient
    @State private var currentDate = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                // Time-based gradient background
                GradientBackground(timeOfDay: currentDate.timeOfDay)

                VStack(spacing: 0) {
                    // Top Navigation Bar - Settings only
                    HStack {
                        Spacer()

                        // Settings Icon
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.9))
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
                                .foregroundColor(.white)

                            Text(currentDate.friendlyDateString)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                        // Main Glass Card
                        GlassCard(padding: 25) {
                            VStack(spacing: 25) {
                                // Question
                                Text("How are you feeling right now?")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
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

                                // Note Input Field
                                VStack(spacing: 12) {
                                    TextField("Add a note...", text: $note, axis: .vertical)
                                        .textFieldStyle(.plain)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.1))
                                        )
                                        .lineLimit(3...5)
                                        .focused($isNoteFieldFocused)

                                    // Photo and Voice Buttons
                                    attachmentButtonsView
                                }

                                // Save Mood Button
                                GlowingButton(
                                    title: "Save Mood",
                                    action: logMood,
                                    isEnabled: selectedMood != nil,
                                    colors: [Color(hex: "FFD93D"), Color(hex: "FFA500")]
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isNoteFieldFocused = false
                    }
                }
            }
            .alert("Mood Logged!", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your mood has been recorded! ✨")
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                    }
                }
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
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            HStack(spacing: 8) {
                Image(systemName: selectedPhotoData != nil ? "photo.fill" : "photo")
                    .font(.system(size: 20))
                    .foregroundColor(selectedPhotoData != nil ? Color(hex: "667EEA") : .primary)

                Text(selectedPhotoData != nil ? "Photo Added" : "Add Photo")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(selectedPhotoData != nil ? Color(hex: "667EEA") : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedPhotoData != nil ? Color(hex: "667EEA").opacity(0.15) : Color.gray.opacity(0.1))
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
            return Color(hex: "667EEA")
        } else {
            return .primary
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
            return Color(hex: "667EEA")
        } else {
            return .primary
        }
    }

    private var voiceButtonBackground: Color {
        if isRecording {
            return Color.red.opacity(0.15)
        } else if recordedAudioData != nil {
            return Color(hex: "667EEA").opacity(0.15)
        } else {
            return Color.gray.opacity(0.1)
        }
    }

    // MARK: - Functions

    private func logMood() {
        guard let mood = selectedMood else { return }

        // Dismiss keyboard
        isNoteFieldFocused = false

        dataManager.addEntry(
            mood: mood,
            note: note,
            photoData: selectedPhotoData,
            audioData: recordedAudioData,
            audioDuration: recordedAudioData != nil ? audioDuration : nil
        )

        // Clear form
        selectedMood = nil
        note = ""
        selectedPhotoData = nil
        selectedPhotoItem = nil
        recordedAudioData = nil
        audioDuration = 0

        showingSaveAlert = true
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

#Preview {
    HomeView()
        .environmentObject(DataManager())
}
