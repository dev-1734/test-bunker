import Foundation

struct CatalogSnapshot: Codable {
    let catalog: QuizCatalog

    func validated() throws -> CatalogSnapshot {
        guard !catalog.tracks.isEmpty else { throw CatalogLoadError.emptyCatalog }
        return self
    }
}

enum CatalogSource: String {
    case remote
    case cache
    case bundled
}

enum CatalogLoadError: LocalizedError {
    case bundledCatalogMissing
    case emptyCatalog
    case invalidHTTPStatus(Int)

    var errorDescription: String? {
        switch self {
        case .bundledCatalogMissing: return "Bundled catalog.json not found."
        case .emptyCatalog: return "The music catalog is empty."
        case .invalidHTTPStatus(let status): return "Catalog server returned HTTP \(status)."
        }
    }
}
