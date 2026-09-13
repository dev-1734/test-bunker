import XCTest
@testable import MusicQuizCoreSmoke

final class MusicQuizCoreSmokeTests: XCTestCase {
    func testSearchNormalizationAndMatching() {
        let track = makeTrack(id: "1", title: "Super Shy", artist: "NewJeans")
        XCTAssertTrue(track.matchesSearch("super shy"))
        XCTAssertTrue(track.matchesSearch("new jeans"))
        XCTAssertEqual(QuizTrack.normalized("Super-Shy!"), "supershy")
    }

    func testRankedSearchPrefersExactTitleOverArtistMatch() {
        let exactTitle = makeTrack(id: "title", title: "Ditto", artist: "NewJeans")
        let artistMatch = makeTrack(id: "artist", title: "Another Song", artist: "Ditto")
        XCTAssertEqual(QuizSearch.suggestions(for: "Ditto", in: [artistMatch, exactTitle]).first?.id, exactTitle.id)
    }

    func testRankedSearchDeduplicatesSameArtistAndTitle() {
        let a = makeTrack(id: "album", title: "Drama", artist: "aespa")
        let b = makeTrack(id: "single", title: "Drama", artist: "aespa")
        XCTAssertEqual(QuizSearch.suggestions(for: "Drama", in: [a, b]).count, 1)
    }

    func testDailyPickerIsDeterministicForSameDate() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date(timeIntervalSince1970: 1_725_984_000)
        let tracks = (0..<8).map { makeTrack(id: "track-\($0)", title: "Song \($0)", artist: "Artist \($0)") }
        let first = DailyQuizPicker.track(for: date, from: tracks, calendar: calendar)
        let second = DailyQuizPicker.track(for: date, from: tracks.reversed(), calendar: calendar)
        XCTAssertEqual(first?.id, second?.id)
    }

    func testPublishedDailyScheduleWins() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: DateComponents(year: 2026, month: 9, day: 13))!
        let tracks = [makeTrack(id: "a", title: "A", artist: "Artist"), makeTrack(id: "b", title: "B", artist: "Artist")]
        let schedule = DailySchedule(schemaVersion: 1, generatedAt: nil, entries: ["2026-09-13": "b"])
        XCTAssertEqual(DailyQuizPicker.track(for: date, from: tracks, schedule: schedule, calendar: calendar)?.id, "b")
    }

    func testSnapshotRejectsMissingScheduledTrack() {
        let catalog = QuizCatalog(generatedAt: "v1", tracks: [makeTrack(id: "a", title: "A", artist: "Artist")])
        let schedule = DailySchedule(schemaVersion: 1, generatedAt: nil, entries: ["2026-09-13": "missing"])
        XCTAssertThrowsError(try CatalogSnapshot(catalog: catalog, schedule: schedule).validated())
    }

    func testClipProgressionContract() {
        var progression = QuizProgression()
        for expected in [1.0, 2, 4, 7, 11, 16] {
            XCTAssertEqual(progression.currentClipDuration, expected)
            progression.advanceAfterMiss()
        }
        XCTAssertTrue(progression.isFinished)
        XCTAssertEqual(progression.attemptNumber, 6)
    }

    func testSolvedProgressionFinishesWithoutAdvancingAttempt() {
        var progression = QuizProgression()
        progression.advanceAfterMiss()
        progression.advanceAfterMiss()
        progression.finishSolved()
        XCTAssertTrue(progression.isFinished)
        XCTAssertEqual(progression.attemptNumber, 3)
        XCTAssertEqual(progression.currentClipDuration, 4)
    }

    @MainActor
    func testClipPlayerRejectsNonHTTPSPreview() {
        let player = ClipPlayer()
        player.prepare(url: URL(string: "http://example.com/preview.m4a")!)
        XCTAssertFalse(player.isPlaying)
        XCTAssertNotNil(player.lastError)
    }

    private func makeTrack(id: String, title: String, artist: String) -> QuizTrack {
        QuizTrack(id: id, title: title, artist: artist, source: .applePreview,
                  previewURL: "https://example.com/\(id).m4a", storeURL: nil,
                  artworkURL: nil, releaseDate: "2024-01-01", providerTrackID: id)
    }
}
