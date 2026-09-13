import Foundation

struct QuizProgression {
    static let clipDurations: [TimeInterval] = [1, 2, 4, 7, 11, 16]

    private(set) var attempt = 0

    var currentClipDuration: TimeInterval {
        Self.clipDurations[min(attempt, Self.clipDurations.count - 1)]
    }

    var isFinished: Bool {
        attempt >= Self.clipDurations.count
    }

    mutating func advance() {
        guard !isFinished else { return }
        attempt += 1
    }
}
