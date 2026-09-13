import Foundation

struct QuizProgression {
    static let clipDurations: [TimeInterval] = [1, 2, 4, 7, 11, 16]

    private(set) var attemptIndex = 0
    private(set) var isFinished = false

    var maxAttempts: Int { Self.clipDurations.count }

    var attemptNumber: Int {
        min(attemptIndex + 1, maxAttempts)
    }

    var currentClipDuration: TimeInterval {
        Self.clipDurations[min(attemptIndex, maxAttempts - 1)]
    }

    mutating func advanceAfterMiss() {
        guard !isFinished else { return }
        attemptIndex += 1
        if attemptIndex >= maxAttempts {
            isFinished = true
        }
    }

    mutating func finishSolved() {
        guard !isFinished else { return }
        isFinished = true
    }
}
