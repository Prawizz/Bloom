import SwiftUI

struct AnalysisView: View {

    @Environment(MoodViewModel.self) var moodViewModel
    @Environment(JournalViewModel.self) var journalViewModel

    @State private var analysis: String = ""
    @State private var isLoading = false
    
    // Theme Colors
    private let textBrown = Color(red: 0.4, green: 0.3, blue: 0.2)

    var body: some View {
        VStack(spacing: 20) {

            Text("Therapist Room 🌿")
                .font(.custom("DarumadropOne-Regular", size: 32))
                .foregroundColor(textBrown)
                .shadow(color: .white.opacity(0.5), radius: 2)

            if isLoading {
                VStack(spacing: 15) {
                    ProgressView()
                        .tint(textBrown)
                    Text("Analyzing your moods...")
                        .font(.custom("DarumadropOne-Regular", size: 18))
                        .foregroundColor(textBrown)
                }
                .frame(maxHeight: .infinity)
            } else if !analysis.isEmpty {
                // --- THE STYLED ANALYSIS BOX ---
                ScrollView {
                    Text(analysis)
                        .font(.custom("DarumadropOne-Regular", size: 18))
                        .foregroundColor(textBrown)
                        .lineSpacing(6)
                        .padding(25)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        // Using 0.85 opacity for better visibility
                        .fill(Color.white.opacity(0.85))
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                )
                .padding(.horizontal, 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                VStack {
                    Spacer()
                    // Small placeholder box so it's not just floating text
                    Text("Ready to grow? Tap analyze below.")
                        .font(.custom("DarumadropOne-Regular", size: 18))
                        .foregroundColor(textBrown)
                        .padding()
                        .background(Capsule().fill(Color.white.opacity(0.6)))
                    Spacer()
                }
            }
            // Action Button
            Button {
                withAnimation(.spring()) {
                    generateAnalysis()
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Analyze My Mood")
                }
                .font(.custom("DarumadropOne-Regular", size: 22))
                .frame(maxWidth: .infinity)
                .padding()
                .background(textBrown)
                .foregroundColor(.white)
                .cornerRadius(100)
                .shadow(color: textBrown.opacity(0.4), radius: 10, y: 5)
            }
            .padding(.bottom, 20)
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
                    withAnimation {
                        analysis = result
                        isLoading = false
                    }
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
