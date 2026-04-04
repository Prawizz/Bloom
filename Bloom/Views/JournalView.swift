import SwiftUI

struct JournalView: View {
    let entryDate: Date
    @State private var moodNotes: String = ""
    @State private var highsAndLows: String = ""

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: entryDate)
    }

    var body: some View {
        Form {
            Section(header: Text("Journal for \(formattedDate)")) {
                TextEditor(text: $moodNotes)
                    .frame(minHeight: 150)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                    .padding(.vertical, 4)
                    .background(Color(UIColor.systemBackground))

                TextEditor(text: $highsAndLows)
                    .frame(minHeight: 150)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                    .padding(.vertical, 4)
                    .background(Color(UIColor.systemBackground))
            }

            Section {
                Button(action: saveEntry) {
                    Text("Save Entry")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveEntry() {
        // Placeholder: Integrate persistence or data store later.
        print("Saved journal for \(formattedDate):\nMood/Notes:\n\(moodNotes)\nHighs/Lows:\n\(highsAndLows)")
    }
}

#Preview {
    JournalView(entryDate: Date())
}
