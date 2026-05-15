import SwiftUI

struct JournalView: View {
    let entryDate: Date
    @State private var notes: String = ""
    @State private var flowerType: String = "rose"
    @State private var mood: Int = 3
    @State private var sleepHours: Double = 8.0
    @State private var steps: Int = 0
    
    // 👇 Custom design alert overlay state tracking variables
    @State private var showSavedAlert = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(JournalViewModel.self) var journalViewModel
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
            .blur(radius: showSavedAlert ? 5 : 0) // Softly blurs underlying fields when saving popped up
            
            // 👇 COZY CUSTOM DESIGN SAVED DIALOG OVERLAY BLOCK
            if showSavedAlert {
                ZStack {
                    // Dark background dimming matte
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showSavedAlert = false; dismiss() }
                        }
                    
                    // Alert Window Chassis
                    VStack(spacing: 24) {
                        // Dynamic Plant Decoration Node
                        Image("\(flowerType)_\(mood)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .padding(.top, 10)
                        
                        VStack(spacing: 8) {
                            Text("Entry Saved!")
                                .font(.custom("DarumadropOne-Regular", size: 30))
                                .foregroundColor(textBrown)
                            
                            Text("Your garden is growing beautifully.")
                                .font(.custom("DarumadropOne-Regular", size: 16))
                                .foregroundColor(textBrown.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                        
                        // Custom Button Stylized Block
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.15)) {
                                showSavedAlert = false
                                dismiss()
                            }
                        }) {
                            Text("Yay!")
                                .font(.custom("DarumadropOne-Regular", size: 20))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(textBrown)
                                .cornerRadius(100)
                                .shadow(color: textBrown.opacity(0.2), radius: 5, y: 3)
                        }
                    }
                    .padding(30)
                    .frame(width: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(softBeige)
                            .overlay(RoundedRectangle(cornerRadius: 28).stroke(textBrown.opacity(0.15), lineWidth: 2))
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .transition(.scale.combined(with: .opacity)) // Smooth scale-pop effect animation setup
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadExistingEntry() }
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
        let entry = JournalEntry(
            date: entryDate,
            mood: mood,
            notes: notes,
            flowerType: flowerType,
            sleepHours: sleepHours,
            steps: steps
        )
        journalViewModel.addEntry(entry)
        moodViewModel.setMood(mood, for: entryDate)
        
        // Triggers the custom animated overlay view framework instantly
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showSavedAlert = true
        }
    }
}
