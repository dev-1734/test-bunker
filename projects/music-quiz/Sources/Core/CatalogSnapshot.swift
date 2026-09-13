import Foundation

struct CatalogSnapshot: Codable {
    let catalog: QuizCatalog
    let schedule: DailySchedule

    func validated() throws -> CatalogSnapshot {
        guard !catalog.tracks.isEmpty else { throw CatalogLoadError.emptyCatalog }
        let ids = Set(catalog.tracks.map(\.id))
        let missing = Set(schedule.entries.values).subtracting(ids)
        guard missing.isEmpty else { throw CatalogLoadError.scheduleReferencesMissingTracks(missing.count) }
        return self
    }
}

enum CatalogLoadError: Error {
    case emptyCatalog
    case scheduleReferencesMissingTracks(Int)
}
