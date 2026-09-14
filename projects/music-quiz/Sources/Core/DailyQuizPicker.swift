import Foundation

enum DailyQuizPicker {
    static func dateKey(for date: Date = Date(), calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    static func track(for date: Date = Date(), from tracks: [QuizTrack], calendar: Calendar = .current) -> QuizTrack? {
        guard !tracks.isEmpty else { return nil }
        let sorted = tracks.sorted { $0.id < $1.id }
        let key = dateKey(for: date, calendar: calendar)
        let index = Int(stableHash(key) % UInt64(sorted.count))
        return sorted[index]
    }

    private static func stableHash(_ value: String) -> UInt64 {
        var hash: UInt64 = 1_469_598_103_934_665_603
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return hash
    }
}
