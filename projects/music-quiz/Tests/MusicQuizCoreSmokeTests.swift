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

        let results = QuizSearch.suggestions(for: "Ditto", in: [artistMatch, exactTitle])
        XCTAssertEqual(results.first?.id, exactTitle.id)
    }

    func testRankedSearchDeduplicatesSameArtistAndTitle() {
        let albumVersion = makeTrack(id: "album", title: "Drama", artist: "aespa")
        let singleVersion = makeTrack(id: "single", title: "Drama", artist: "aespa")

        let results = QuizSearch.suggestions(for: "Drama", in: [albumVersion, singleVersion])
        XCTAssertEqual(results.count, 1)
    }

    func testDailyPickerIsDeterministicForSameDate() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date(timeIntervalSince1970: 1_725_984_000)
        let tracks = (0..<8).map { index in
            makeTrack(id: "track-\(index)", title: "Song \(index)", artist: "Artist \(index)")
        }

        let first = DailyQuizPicker.track(for: date, from: tracks, calendar: calendar)
        let second = DailyQuizPicker.track(for: date, from: tracks.reversed(), calendar: calendar)
        XCTAssertEqual(first?.id, second?.id)
    }

    func testClipProgressionContract() {
        var progression = QuizProgression()
        XCTAssertEqual(progression.currentClipDuration, 1)
        XCTAssertEqual(progression.attemptNumber, 1)
        XCTAssertFalse(progression.isFinished)

        progression.advanceAfterMiss()
        XCTAssertEqual(progression.currentClipDuration, 2)
        progression.advanceAfterMiss()
        XCTAssertEqual(progression.currentClipDuration, 4)
        progression.advanceAfterMiss()
        XCTAssertEqual(progression.currentClipDuration, 7)
        progression.advanceAfterMiss()
        XCTAssertEqual(progression.currentClipDuration, 11)
        progression.advanceAfterMiss()
        XCTAssertEqual(progression.currentClipDuration, 16)
        XCTAssertFalse(progression.isFinished)

        progression.advanceAfterMiss()
        XCTAssertTrue(progression.isFinished)
        XCTAssertEqual(progression.attemptNumber, 6)
    }

    func testSolvedProgressionFinishesWithoutAdvancingAttempt() {
        var progression = QuizProgression()
        progression.advanceAfterMiss()
        progression.advanceAfterMiss()
        XCTAssertEqual(progression.attemptNumber, 3)

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
        QuizTrack(
            id: id,
            title: title,
            artist: artist,
            source: .applePreview,
            previewURL: "https://example.com/\(id).m4a",
            storeURL: nil,
            artworkURL: nil,
            releaseDate: "2024-01-01",
            providerTrackID: id
        )
    }
}
