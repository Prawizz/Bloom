import Foundation
import FirebaseFirestore

// Journal entry — stores everything user inputs per day
struct JournalEntry: Identifiable, Codable {
    var id: String          // String for Firestore
    var date: Date
    var mood: Int           // 1-5 rating
    var notes: String       // user's written journal
    var flowerType: String  // flower visual for calendar
    var sleepHours: Double  // how many hours they slept
    var steps: Int          // steps walked that day

    init(
        id: String = UUID().uuidString,
        date: Date,
        mood: Int,
        notes: String,
        flowerType: String,
        sleepHours: Double = 8.0,
        steps: Int = 0
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.notes = notes
        self.flowerType = flowerType
        self.sleepHours = sleepHours
        self.steps = steps
    }
}

// Mood entry — lightweight, just tracks mood per day
struct MoodEntry: Identifiable, Codable {
    var id: String = UUID().uuidString  // String for Firestore
    var date: Date
    var mood: Int
}
