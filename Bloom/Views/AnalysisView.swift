import SwiftUI

struct AnalysisView: View {
    
    @Environment(MoodViewModel.self) var moodViewModel
    @Environment(JournalViewModel.self) var journalViewModel
    
    @State private var analysis: String = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Your Insights 🌿")
                .font(.title2)
                .fontWeight(.semibold)
            
            if isLoading {
                ProgressView("Analyzing your moods...")
            }
            
            else if !analysis.isEmpty {
                Text(analysis)
                    .padding()
                    .background(Color("SoftPink").opacity(0.2))
                    .cornerRadius(16)
            }
            
            else {
                Text("No analysis yet")
                    .foregroundColor(.gray)
            }
            
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
    
    // MARK: - AI Function
    
    func generateAnalysis() {
        isLoading = true
        
        Task {
            do {
                let result = try await LLMService.shared.analyze(
                    moods: moodViewModel.recentMoods,
                    journals: journalViewModel.recentEntries
                )
                
                analysis = result
            } catch {
                analysis = "Failed to analyze. Try again."
            }
            
            isLoading = false
        }
    }
}

#Preview {
    AnalysisView()
        .environment(MoodViewModel())
        .environment(JournalViewModel())
}
