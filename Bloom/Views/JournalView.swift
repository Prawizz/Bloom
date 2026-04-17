import SwiftUI

struct JournalView: View {
    let entryDate: Date
    @State private var notes: String = ""
    @State private var flowerType: String = "rose"
    @State private var mood: Int = 3
    @State private var sleepHours: Double = 8.0
    @State private var steps: Int = 0
    @Environment(JournalViewModel.self) var journalViewModel

    private let flowerOptions = ["rose", "tulip", "sunflower", "daisy", "lily"]

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: entryDate)
    }

    var body: some View {
        Form {
            Section(header: Text("Journal for \(formattedDate)")) {
                // Flower Type Selection
                Picker("Choose Flower", selection: $flowerType) {
                    ForEach(flowerOptions, id: \.self) { flower in
                        Text(flower.capitalized).tag(flower)
                    }
                }
                .pickerStyle(.menu)
            }

            Section(header: Text("How are you feeling? (1-5)")) {
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { level in
                        Button(action: { mood = level }) {
                            VStack {
                                Text(flowerEmoji(for: flowerType, mood: level))
                                    .font(.largeTitle)
                                Text("\(level)")
                                    .font(.caption)
                            }
                            .padding()
                            .background(mood == level ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
            }

            Section(header: Text("Sleep & Activity")) {
                Stepper(value: $sleepHours, in: 0...16, step: 0.25) {
                    HStack {
                        Text("Sleep")
                        Spacer()
                        Text("\(sleepHours, specifier: "%.2f") hrs")
                    }
                }
                Stepper(value: $steps, in: 0...50000, step: 250) {
                    HStack {
                        Text("Steps")
                        Spacer()
                        Text("\(steps)")
                    }
                }
            }

            Section(header: Text("Notes")) {
                TextEditor(text: $notes)
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
        .onAppear {
            if let existingEntry = journalViewModel.entry(for: entryDate) {
                notes = existingEntry.notes
                flowerType = existingEntry.flowerType
                mood = existingEntry.mood
                sleepHours = existingEntry.sleepHours
                steps = existingEntry.steps
            }
        }
    }

    private func flowerEmoji(for flowerType: String, mood: Int) -> String {
        let baseEmoji: String
        switch flowerType {
        case "rose": baseEmoji = "🌹"
        case "tulip": baseEmoji = "🌷"
        case "sunflower": baseEmoji = "🌻"
        case "daisy": baseEmoji = "🌼"
        case "lily": baseEmoji = "🌸"
        default: baseEmoji = "🌱"
        }
        
        // Vary witheredness: fresh for high mood, wilted for low
        switch mood {
        case 5: return baseEmoji  // Fresh
        case 4: return baseEmoji
        case 3: return "🥀"  // Wilted placeholder
        case 2: return "🥀"
        case 1: return "🥀"
        default: return baseEmoji
        }
    }

    private func saveEntry() {
        let entry = JournalEntry(
            date: entryDate,
            mood: mood,
            notes: notes,
            flowerType: flowerType,
            sleepHours: sleepHours,
            steps: steps
        )
        journalViewModel.addEntry(entry)
    }
}

#Preview {
    JournalView(entryDate: Date())
        .environment(JournalViewModel())
}
