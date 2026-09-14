import Foundation

struct CatalogLoader {
    static let catalogFreshness: TimeInterval = 7 * 24 * 60 * 60

    let remote: CatalogRemote
    let local: CatalogLocal
    let remoteCatalogURL: URL?
    let now: () -> Date

    init(
        session: URLSession = .shared,
        bundle: Bundle = .main,
        fileManager: FileManager = .default,
        cacheDirectory: URL? = nil,
        remoteCatalogURL: URL? = nil,
        useConfiguredRemote: Bool = true,
        now: @escaping () -> Date = Date.init
    ) {
        self.remote = CatalogRemote(session: session)
        self.local = CatalogLocal(bundle: bundle, fileManager: fileManager, cacheDirectory: cacheDirectory)
        self.remoteCatalogURL = remoteCatalogURL ?? (useConfiguredRemote ? Self.configuredURL("RemoteCatalogURL", bundle: bundle) : nil)
        self.now = now
    }

    func load() async throws -> (CatalogSnapshot, CatalogSource) {
        let cached = local.cached()
        if let cached, isFresh(cached.catalog) {
            return (cached, .cache)
        }
        if let remoteCatalogURL {
            do {
                let snapshot = try await remote.load(catalogURL: remoteCatalogURL)
                try local.save(snapshot)
                return (snapshot, .remote)
            } catch {
                // A transient network/server failure must never prevent gameplay.
            }
        }
        if let cached { return (cached, .cache) }
        return (try local.bundled(), .bundled)
    }

    private func isFresh(_ catalog: QuizCatalog) -> Bool {
        guard let generatedAt = catalog.generatedAt,
              let generatedDate = ISO8601DateFormatter().date(from: generatedAt) else { return false }
        let age = now().timeIntervalSince(generatedDate)
        return age >= 0 && age < Self.catalogFreshness
    }

    private static func configuredURL(_ key: String, bundle: Bundle) -> URL? {
        guard let raw = bundle.object(forInfoDictionaryKey: key) as? String,
              !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return URL(string: raw)
    }
}
