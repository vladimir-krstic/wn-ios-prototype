import AVFoundation
import Foundation

/// Coordinates deterministic playback without microphone access.
/// Every voice bubble plays the same locally bundled recording.
@MainActor
final class PrototypePlaybackCoordinator: NSObject, ObservableObject,
    AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate
{
    static let shared = PrototypePlaybackCoordinator()

    @Published private(set) var activeVoiceID: String?
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isPaused = false
    @Published private(set) var activeSpokenMessageID: String?
    @Published private(set) var spokenProgress: Double = 0
    @Published private var registeredWaveforms: [String: [Double]] = [:]

    private var player: AVAudioPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var activeSpeechUtteranceID: ObjectIdentifier?
    private var progressTask: Task<Void, Never>?

    override private init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    func toggleVoice(id: String, duration requestedDuration: TimeInterval) {
        if activeVoiceID == id {
            if isPaused {
                player?.play()
                isPaused = false
                startProgress()
            } else {
                player?.pause()
                isPaused = true
                progressTask?.cancel()
            }
            return
        }

        stopAll()
        guard let player = try? AVAudioPlayer(data: PrototypeVoiceSample.data) else { return }
        self.player = player
        player.delegate = self
        player.prepareToPlay()
        let playbackDuration = max(0.1, requestedDuration)
        if playbackDuration > player.duration {
            player.numberOfLoops = -1
        }
        activeVoiceID = id
        duration = playbackDuration
        elapsed = 0
        isPaused = false
        player.play()
        startProgress()
    }

    func registerWaveform(_ samples: [Double], for id: String) {
        registeredWaveforms[id] = samples
    }

    func waveform(for id: String) -> [Double] {
        registeredWaveforms[id] ?? PrototypeWaveformSamples.samples(seed: id)
    }

    func readAloud(messageID: String, text: String) {
        let spokenText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spokenText.isEmpty else { return }

        stopAll()
        let utterance = AVSpeechUtterance(string: spokenText)
        activeSpeechUtteranceID = ObjectIdentifier(utterance)
        activeSpokenMessageID = messageID
        spokenProgress = 0
        speechSynthesizer.speak(utterance)
    }

    func stopReading() {
        guard activeSpeechUtteranceID != nil
                || activeSpokenMessageID != nil
                || speechSynthesizer.isSpeaking
                || speechSynthesizer.isPaused
        else { return }

        activeSpeechUtteranceID = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
        activeSpokenMessageID = nil
        spokenProgress = 0
    }

    func stopAll() {
        let hadVoicePlayback = progressTask != nil
            || player != nil
            || activeVoiceID != nil
            || elapsed != 0
            || duration != 0
            || isPaused

        progressTask?.cancel()
        progressTask = nil
        player?.stop()
        player = nil
        if hadVoicePlayback {
            activeVoiceID = nil
            elapsed = 0
            duration = 0
            isPaused = false
        }
        stopReading()
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in self?.stopAll() }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        let utteranceID = ObjectIdentifier(utterance)
        let characterCount = utterance.speechString.utf16.count
        let spokenCharacterCount = min(NSMaxRange(characterRange), characterCount)
        Task { @MainActor [weak self] in
            guard self?.activeSpeechUtteranceID == utteranceID else { return }
            self?.spokenProgress = characterCount > 0
                ? min(max(Double(spokenCharacterCount) / Double(characterCount), 0), 1)
                : 0
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        let utteranceID = ObjectIdentifier(utterance)
        Task { @MainActor [weak self] in
            guard self?.activeSpeechUtteranceID == utteranceID else { return }
            self?.activeSpeechUtteranceID = nil
            self?.activeSpokenMessageID = nil
            self?.spokenProgress = 0
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        let utteranceID = ObjectIdentifier(utterance)
        Task { @MainActor [weak self] in
            guard self?.activeSpeechUtteranceID == utteranceID else { return }
            self?.activeSpeechUtteranceID = nil
            self?.activeSpokenMessageID = nil
            self?.spokenProgress = 0
        }
    }

    private func startProgress() {
        progressTask?.cancel()
        progressTask = Task { @MainActor in
            while !Task.isCancelled, activeVoiceID != nil, !isPaused {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                elapsed = min(duration, elapsed + 0.1)
                if elapsed >= duration {
                    stopAll()
                    return
                }
            }
        }
    }
}
