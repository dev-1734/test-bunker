import Foundation

enum QuizSearch {
    static func suggestions(
        for query: String,
        in tracks: [QuizTrack],
        limit: Int = 6
    ) -> [QuizTrack] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let needle = QuizTrack.normalized(trimmed)
        guard !needle.isEmpty, limit > 0 else { return [] }

        var bestBySong: [String: (track: QuizTrack, score: Int)] = [:]

        for track in tracks {
            guard let score = score(track: track, needle: needle) else { continue }
            let key = "\(QuizTrack.normalized(track.artist))|\(QuizTrack.normalized(track.title))"

            if let existing = bestBySong[key] {
                if score > existing.score
                    || (score == existing.score
                        && track.searchLabel.localizedCaseInsensitiveCompare(existing.track.searchLabel) == .orderedAscending) {
                    bestBySong[key] = (track, score)
                }
            } else {
                bestBySong[key] = (track, score)
            }
        }

        return Array(
            bestBySong.values
                .sorted {
                    if $0.score != $1.score { return $0.score > $1.score }
                    return $0.track.searchLabel.localizedCaseInsensitiveCompare($1.track.searchLabel) == .orderedAscending
                }
                .prefix(limit)
                .map(\.track)
        )
    }

    private static func score(track: QuizTrack, needle: String) -> Int? {
        let title = QuizTrack.normalized(track.title)
        let artist = QuizTrack.normalized(track.artist)
        let label = QuizTrack.normalized(track.searchLabel)

        if title == needle { return 1_000 }
        if label == needle { return 950 }
        if artist == needle { return 900 }
        if title.hasPrefix(needle) { return 800 }
        if artist.hasPrefix(needle) { return 700 }
        if label.hasPrefix(needle) { return 650 }
        if title.contains(needle) { return 500 }
        if artist.contains(needle) { return 400 }
        if label.contains(needle) { return 300 }
        return nil
    }
}
