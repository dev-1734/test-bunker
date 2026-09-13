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
        lastError = nil

        guard url.scheme?.lowercased() == "https" else {
            lastError = "This preview URL is not supported."
            player = nil
            return
        }

        player = AVPlayer(playerItem: AVPlayerItem(url: url))
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            lastError = "Audio playback could not be prepared."
        }
    }

    func play(seconds: TimeInterval, startAt: TimeInterval = 0) {
        guard let player else {
            lastError = "This preview is currently unavailable."
            return
        }
        guard lastError == nil else { return }

        removeObserver()

        let safeStart = max(0, startAt)
        let safeDuration = max(0.1, seconds)
        let start = CMTime(seconds: safeStart, preferredTimescale: 600)
        let end = CMTime(seconds: safeStart + safeDuration, preferredTimescale: 600)
        stopAt = end

        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if let itemError = player.currentItem?.error {
                    self.failPlayback(itemError)
                    return
                }
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
                guard let self else { return }

                if let itemError = player.currentItem?.error {
                    self.failPlayback(itemError)
                    return
                }

                guard let stopAt = self.stopAt else { return }
                if current >= stopAt { self.stop() }
            }
        }
    }

    private func failPlayback(_ error: Error) {
        player?.pause()
        isPlaying = false
        removeObserver()
        lastError = "This preview could not be played. Please try again."
    }

    private func removeObserver() {
        if let observer, let player {
            player.removeTimeObserver(observer)
        }
        observer = nil
    }
}
