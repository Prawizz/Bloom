import SwiftUI

struct AnalysisView: View {

    @Environment(MoodViewModel.self) var moodViewModel
    @Environment(JournalViewModel.self) var journalViewModel

    @State private var analysis: String = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {

            Text("Therapist Room 🌿")
                .font(.title2)
                .fontWeight(.semibold)

            if isLoading {
                ProgressView("Analyzing your moods...")
            } else if !analysis.isEmpty {
                ScrollView {
                    Text(analysis)
                        .padding()
                        .background(Color("SoftPink").opacity(0.2))
                        .cornerRadius(16)
                }
            } else {
                Text("No analysis yet")
                    .foregroundColor(.gray)
            }

            Text("Moods: \(moodViewModel.recentMoods.count) | Journals: \(journalViewModel.recentEntries.count)")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                generateAnalysis()
            } label: {
                Text("Analyze My Mood")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }

    func generateAnalysis() {
        isLoading = true
        analysis = ""

        Task {
            do {
                let result = try await LLMService.shared.analyze(
                    moods: moodViewModel.recentMoods,
                    journals: journalViewModel.recentEntries
                )
                await MainActor.run {
                    analysis = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    analysis = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AnalysisView()
        .environment(MoodViewModel())
        .environment(JournalViewModel())
}
