import Foundation
// อันนี้คือ model เก็บ journal ของแต่ละวันใช่ปะ แบบเราจะให้ user input อะไรให้กับเราใน journal บ้าง
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: Int
    let notes: String
    let flowerType: String
    
    init(date: Date, mood: Int, notes: String, flowerType: String) {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.notes = notes
        self.flowerType = flowerType
    }
}

struct MoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var mood: Int
}
