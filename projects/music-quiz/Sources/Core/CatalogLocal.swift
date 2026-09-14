import Foundation

struct CatalogLocal {
    let bundle: Bundle
    let fileManager: FileManager
    let cacheDirectory: URL?

    init(bundle: Bundle = .main, fileManager: FileManager = .default, cacheDirectory: URL? = nil) {
        self.bundle = bundle
        self.fileManager = fileManager
        self.cacheDirectory = cacheDirectory
    }

    func bundled() throws -> CatalogSnapshot {
        guard let catalogURL = bundle.url(forResource: "catalog", withExtension: "json") else {
            throw CatalogLoadError.bundledCatalogMissing
        }
        let catalog = try JSONDecoder().decode(QuizCatalog.self, from: Data(contentsOf: catalogURL))
        return try CatalogSnapshot(catalog: catalog).validated()
    }

    func cached() -> CatalogSnapshot? {
        guard let url = try? cacheURL(), fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(CatalogSnapshot.self, from: data),
              let validated = try? snapshot.validated() else { return nil }
        return validated
    }

    func save(_ snapshot: CatalogSnapshot) throws {
        let validated = try snapshot.validated()
        let url = try cacheURL()
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(validated).write(to: url, options: .atomic)
    }

    private func cacheURL() throws -> URL {
        let base: URL
        if let cacheDirectory {
            base = cacheDirectory
        } else if let system = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            base = system
        } else {
            throw CocoaError(.fileNoSuchFile)
        }
        return base.appendingPathComponent("MusicQuiz", isDirectory: true)
            .appendingPathComponent("catalog-snapshot.json")
    }
}
