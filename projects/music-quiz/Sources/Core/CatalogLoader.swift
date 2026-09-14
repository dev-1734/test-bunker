import Foundation

struct CatalogLoader {
    let remote: CatalogRemote
    let local: CatalogLocal
    let remoteCatalogURL: URL?

    init(
        session: URLSession = .shared,
        bundle: Bundle = .main,
        fileManager: FileManager = .default,
        cacheDirectory: URL? = nil,
        remoteCatalogURL: URL? = nil,
        useConfiguredRemote: Bool = true
    ) {
        self.remote = CatalogRemote(session: session)
        self.local = CatalogLocal(bundle: bundle, fileManager: fileManager, cacheDirectory: cacheDirectory)
        self.remoteCatalogURL = remoteCatalogURL ?? (useConfiguredRemote ? Self.configuredURL("RemoteCatalogURL", bundle: bundle) : nil)
    }

    func load() async throws -> (CatalogSnapshot, CatalogSource) {
        if let remoteCatalogURL {
            do {
                let snapshot = try await remote.load(catalogURL: remoteCatalogURL)
                try local.save(snapshot)
                return (snapshot, .remote)
            } catch {
                // A transient network/server failure must never prevent gameplay.
            }
        }
        if let cached = local.cached() { return (cached, .cache) }
        return (try local.bundled(), .bundled)
    }

    private static func configuredURL(_ key: String, bundle: Bundle) -> URL? {
        guard let raw = bundle.object(forInfoDictionaryKey: key) as? String,
              !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return URL(string: raw)
    }
}
