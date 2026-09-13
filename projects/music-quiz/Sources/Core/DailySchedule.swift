import Foundation

struct DailySchedule: Codable, Equatable {
    let schemaVersion: Int
    let generatedAt: String?
    let entries: [String: String]

    static let empty = DailySchedule(schemaVersion: 1, generatedAt: nil, entries: [:])

    func trackID(for dateKey: String) -> String? { entries[dateKey] }
}
