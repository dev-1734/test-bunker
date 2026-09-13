import SwiftUI

@main
struct MusicQuizCoreSmokeApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Image(systemName: "waveform")
                Text("MusicQuiz Core Smoke")
                    .font(.headline)
                Text("iOS simulator harness")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}
