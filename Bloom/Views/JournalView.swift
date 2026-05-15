import SwiftUI

struct JournalView: View {
    let entryDate: Date
    @State private var notes: String = ""
    @State private var flowerType: String = "rose"
    @State private var mood: Int = 3
    @State private var sleepHours: Double = 8.0
    @State private var steps: Int = 0
    
    @State private var showSavedAlert = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(JournalViewModel.self) var journalViewModel

    private let flowerOptions = ["rose", "tulip", "sunflower", "daisy", "lily"]

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.string(from: entryDate)
    }

    var body: some View {
        Form {
            Section(header: Text("Journal for \(formattedDate)").padding(.top, 5)) {
                Picker("Choose Flower", selection: $flowerType) {
                    ForEach(flowerOptions, id: \.self) { flower in
                        Text(flower.capitalized).tag(flower)
                    }
                }
                .pickerStyle(.menu)
            }

            Section(header: Text("How are you feeling?").padding(.top, 5)) {
                HStack(spacing: 0) {
                    ForEach(1...5, id: \.self) { level in
                        VStack(spacing: 8) {
                            Image("\(flowerType)_\(level)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .grayscale(mood == level ? 0 : 0.5)
                            
                            Text("\(level)")
                                .font(.custom("DarumadropOne-Regular", size: 14))
                                .foregroundColor(mood == level ? .primary : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(mood == level ? Color.green.opacity(0.15) : Color.clear)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            mood = level
                        }
                    }
                }
                .padding(.vertical, 5)
            }

            Section(header: Text("Sleep & Activity").padding(.top, 5)) {
                Stepper(value: $sleepHours, in: 0...16, step: 0.25) {
                    HStack {
                        Text("Sleep")
                        Spacer()
                        Text("\(sleepHours, specifier: "%.2f") hrs").foregroundColor(.secondary)
                    }
                }
                Stepper(value: $steps, in: 0...50000, step: 250) {
                    HStack {
                        Text("Steps")
                        Spacer()
                        Text("\(steps)").foregroundColor(.secondary)
                    }
                }
            }

            Section(header: Text("Notes").padding(.top, 5)) {
                TextEditor(text: $notes)
                    .frame(minHeight: 150)
                    .padding(4)
            }

            Section {
                Button(action: saveEntry) {
                    Text("Save Entry")
                        .font(.custom("DarumadropOne-Regular", size: 20))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.brown.opacity(0.8))
            }
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
        // CHECK FOR EXISTING DATA ON LOAD
        .onAppear {
            loadExistingEntry()
        }
        .alert("Entry Saved!", isPresented: $showSavedAlert) {
            Button("Yay!") {
                dismiss()
            }
        } message: {
            Text("Your garden is growing beautifully.")
        }
    }

    // MARK: - Helper to Load Data
    private func loadExistingEntry() {
        if let existingEntry = journalViewModel.entry(for: entryDate) {
            notes = existingEntry.notes
            flowerType = existingEntry.flowerType
            mood = existingEntry.mood
            sleepHours = existingEntry.sleepHours
            steps = existingEntry.steps
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
        showSavedAlert = true
    }
}
