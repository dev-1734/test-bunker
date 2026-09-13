import AVFoundation
import Foundation
import Observation

@MainActor
@Observable
final class ClipPlayer {
    private var player: AVPlayer?
    private var observer: Any?
    private var stopAt: CMTime?

    private(set) var isPlaying = false
    private(set) var lastError: String?

    func prepare(url: URL) {
        stop()
        player = AVPlayer(playerItem: AVPlayerItem(url: url))
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func play(seconds: TimeInterval, startAt: TimeInterval = 0) {
        guard let player else { return }
        removeObserver()
        let start = CMTime(seconds: startAt, preferredTimescale: 600)
        let end = CMTime(seconds: startAt + seconds, preferredTimescale: 600)
        stopAt = end
        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.installObserver()
                player.play()
                self.isPlaying = true
            }
        }
    }

    func stop() {
        player?.pause()
        isPlaying = false
        removeObserver()
    }

    private func installObserver() {
        guard let player else { return }
        observer = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.03, preferredTimescale: 600),
            queue: .main
        ) { [weak self] current in
            Task { @MainActor in
                guard let self, let stopAt = self.stopAt else { return }
                if current >= stopAt { self.stop() }
            }
        }
    }

    private func removeObserver() {
        if let observer, let player {
            player.removeTimeObserver(observer)
        }
        observer = nil
    }
}
