import Foundation

struct QuizTrack: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let artist: String
    let source: AudioSource
    let previewURL: String
    let storeURL: String?
    let artworkURL: String?
    let releaseDate: String?
    let providerTrackID: String?

    enum AudioSource: String, Codable {
        case applePreview = "apple_preview"
        case licensed = "licensed"
        case youtube = "youtube"
    }

    var playableURL: URL? { URL(string: previewURL) }
    var searchLabel: String { "\(artist) — \(title)" }
    var releaseYear: String? { releaseDate.map { String($0.prefix(4)) } }

    func matchesSearch(_ query: String) -> Bool {
        let needle = Self.normalized(query)
        guard !needle.isEmpty else { return true }
        return Self.normalized(title).contains(needle)
            || Self.normalized(artist).contains(needle)
            || Self.normalized(searchLabel).contains(needle)
    }

    static func normalized(_ value: String) -> String {
        value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "[^a-zA-Z0-9가-힣]", with: "", options: .regularExpression)
            .lowercased()
    }
}

struct QuizCatalog: Codable {
    let generatedAt: String?
    let tracks: [QuizTrack]
}
