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
    // 👇 FIX 1: ADD THE MISSING MOOD VIEW MODEL ENVIRONMENT HERE
    @Environment(MoodViewModel.self) var moodViewModel

    private let flowerOptions = ["rose", "tulip", "sunflower", "daisy", "lily"]
    
    // Theme Colors
    private let textBrown = Color(red: 0.4, green: 0.3, blue: 0.2)
    private let softBeige = Color(red: 0.98, green: 0.96, blue: 0.92)

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.string(from: entryDate)
    }

    var body: some View {
        ZStack {
            softBeige.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // HEADER
                    VStack(spacing: 4) {
                        Text("Journal Entry")
                            .font(.custom("DarumadropOne-Regular", size: 18))
                            .foregroundColor(textBrown.opacity(0.7))
                        Text(formattedDate)
                            .font(.custom("DarumadropOne-Regular", size: 28))
                            .foregroundColor(textBrown)
                    }
                    .padding(.top, 20)

                    // SECTION 1: VISUAL FLOWER PICKER
                    VStack(alignment: .leading, spacing: 10) {
                        Label("SELECT SEEDS", systemImage: "leaf.fill")
                            .font(.custom("DarumadropOne-Regular", size: 16))
                            .foregroundColor(textBrown)
                        
                        HStack(spacing: 8) {
                            ForEach(flowerOptions, id: \.self) { flower in
                                VStack(spacing: 4) {
                                    Image("\(flower)_5")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                    
                                    Text(flower == "sunflower" ? "Sun" : flower.capitalized)
                                        .font(.custom("DarumadropOne-Regular", size: 11))
                                        .foregroundColor(textBrown)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(flowerType == flower ? Color.white : Color.black.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(flowerType == flower ? textBrown.opacity(0.5) : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        flowerType = flower
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.6)))

                    // SECTION 2: MOOD SELECTOR
                    VStack(alignment: .leading) {
                        Text("HOW ARE YOU FEELING?")
                            .font(.custom("DarumadropOne-Regular", size: 16))
                            .foregroundColor(textBrown)
                            .padding(.leading, 5)
                        
                        HStack(spacing: 0) {
                            ForEach(1...5, id: \.self) { level in
                                VStack(spacing: 8) {
                                    Image("\(flowerType)_\(level)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .grayscale(mood == level ? 0 : 0.8)
                                        .scaleEffect(mood == level ? 1.2 : 1.0)
                                    
                                    Text("\(level)")
                                        .font(.custom("DarumadropOne-Regular", size: 16))
                                        .foregroundColor(mood == level ? textBrown : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    withAnimation(.spring()) { mood = level }
                                }
                            }
                        }
                        .padding(.vertical, 15)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.8)))
                    }

                    // SECTION 3: STATS
                    HStack(spacing: 15) {
                        statCard(title: "SLEEP", value: "\(String(format: "%.1f", sleepHours)) hrs", systemImage: "moon.stars.fill") {
                            Stepper("", value: $sleepHours, in: 0...16, step: 0.5)
                                .labelsHidden()
                        }
                        
                        statCard(title: "STEPS", value: "\(steps)", systemImage: "figure.walk") {
                            Stepper("", value: $steps, in: 0...50000, step: 500)
                                .labelsHidden()
                        }
                    }

                    // SECTION 4: NOTES
                    VStack(alignment: .leading) {
                        Text("NOTES")
                            .font(.custom("DarumadropOne-Regular", size: 16))
                            .foregroundColor(textBrown)
                        
                        TextEditor(text: $notes)
                            .font(.custom("DarumadropOne-Regular", size: 18))
                            .frame(minHeight: 120)
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(15)
                            .foregroundColor(textBrown)
                    }

                    // SAVE BUTTON
                    Button(action: saveEntry) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("SAVE ENTRY")
                        }
                        .font(.custom("DarumadropOne-Regular", size: 24))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(textBrown)
                        .foregroundColor(.white)
                        .cornerRadius(100)
                        .shadow(color: textBrown.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadExistingEntry() }
        .alert("Entry Saved!", isPresented: $showSavedAlert) {
            Button("Yay!") { dismiss() }
        } message: {
            Text("Your garden is growing beautifully.")
        }
    }

    @ViewBuilder
    private func statCard<Content: View>(title: String, value: String, systemImage: String, @ViewBuilder control: () -> Content) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.custom("DarumadropOne-Regular", size: 12))
                .foregroundColor(textBrown.opacity(0.8))
            
            Text(value)
                .font(.custom("DarumadropOne-Regular", size: 20))
                .foregroundColor(textBrown)
            
            control()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.6)))
    }

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
        // Save to Journal Collection
        let entry = JournalEntry(
            date: entryDate,
            mood: mood,
            notes: notes,
            flowerType: flowerType,
            sleepHours: sleepHours,
            steps: steps
        )
        journalViewModel.addEntry(entry)
        
        // 👇 FIX 2: SAVE INTO THE MOOD COLLECTION AT THE SAME TIME
        moodViewModel.setMood(mood, for: entryDate)
        
        showSavedAlert = true
    }
}
