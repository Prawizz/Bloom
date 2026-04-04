import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: Int
    
    init(date: Date, mood: Int) {
        self.id = UUID()
        self.date = date
        self.mood = mood
    }
}
