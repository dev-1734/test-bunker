import Foundation

struct CatalogRemote {
    let session: URLSession

    func load(catalogURL: URL) async throws -> CatalogSnapshot {
        let catalogData = try await fetch(catalogURL)
        let catalog = try JSONDecoder().decode(QuizCatalog.self, from: catalogData)
        return try CatalogSnapshot(catalog: catalog).validated()
    }

    private func fetch(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw CatalogLoadError.invalidHTTPStatus(http.statusCode)
        }
        return data
    }
}
