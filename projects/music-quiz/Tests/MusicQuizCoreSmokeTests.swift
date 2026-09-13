import XCTest
@testable import MusicQuizCoreSmoke

final class MusicQuizCoreSmokeTests: XCTestCase {
    func testSearchNormalizationAndMatching() {
        let track = QuizTrack(
            id: "1",
            title: "Super Shy",
            artist: "NewJeans",
            source: .applePreview,
            previewURL: "https://example.com/preview.m4a",
            storeURL: nil,
            artworkURL: nil,
            releaseDate: "2023-07-07",
            providerTrackID: "1"
        )

        XCTAssertTrue(track.matchesSearch("super shy"))
        XCTAssertTrue(track.matchesSearch("new jeans"))
        XCTAssertEqual(QuizTrack.normalized("Super-Shy!"), "supershy")
    }

    func testDailyPickerIsDeterministicForSameDate() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date(timeIntervalSince1970: 1_725_984_000)
        let tracks = (0..<8).map { index in
            QuizTrack(
                id: "track-\(index)",
                title: "Song \(index)",
                artist: "Artist \(index)",
                source: .applePreview,
                previewURL: "https://example.com/\(index).m4a",
                storeURL: nil,
                artworkURL: nil,
                releaseDate: nil,
                providerTrackID: nil
            )
        }

        let first = DailyQuizPicker.track(for: date, from: tracks, calendar: calendar)
        let second = DailyQuizPicker.track(for: date, from: tracks.reversed(), calendar: calendar)
        XCTAssertEqual(first?.id, second?.id)
    }

    func testClipProgressionContract() {
        var progression = QuizProgression()
        XCTAssertEqual(progression.currentClipDuration, 1)

        progression.advance()
        XCTAssertEqual(progression.currentClipDuration, 2)
        progression.advance()
        XCTAssertEqual(progression.currentClipDuration, 4)
        progression.advance()
        XCTAssertEqual(progression.currentClipDuration, 7)
        progression.advance()
        XCTAssertEqual(progression.currentClipDuration, 11)
        progression.advance()
        XCTAssertEqual(progression.currentClipDuration, 16)
    }
}
