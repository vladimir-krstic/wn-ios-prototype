import AVFoundation
import Foundation

/// Coordinates deterministic playback without microphone access.
/// Every voice bubble plays the same locally bundled recording.
@MainActor
final class PrototypePlaybackCoordinator: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = PrototypePlaybackCoordinator()

    @Published private(set) var activeVoiceID: String?
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isPaused = false
    @Published private var registeredWaveforms: [String: [Double]] = [:]

    private var player: AVAudioPlayer?
    private var progressTask: Task<Void, Never>?

    override private init() {
        super.init()
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

    func stopAll() {
        progressTask?.cancel()
        progressTask = nil
        player?.stop()
        player = nil
        activeVoiceID = nil
        elapsed = 0
        duration = 0
        isPaused = false
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in self?.stopAll() }
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
