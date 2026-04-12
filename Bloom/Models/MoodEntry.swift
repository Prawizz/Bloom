import Foundation
// อันนี้คือ model เก็บ journal ของแต่ละวันใช่ปะ แบบเราจะให้ user input อะไรให้กับเราใน journal บ้าง
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: Int
    let notes: String
    let flowerType: String
    let sleepHours: Double
    let steps: Int
    
    init(date: Date, mood: Int, notes: String, flowerType: String, sleepHours: Double = 8.0, steps: Int = 0) {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.notes = notes
        self.flowerType = flowerType
        self.sleepHours = sleepHours
        self.steps = steps
    }

    // Not sure if encoding จำเป็นมั้ยสำหรับการ save entries ใน session ai ว่ามาว่าถ้าจะเก็บข้อมูลเป็น json encode ก้ดี
    enum CodingKeys: String, CodingKey {
        case id, date, mood, notes, flowerType, sleepHours, steps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try container.decode(Date.self, forKey: .date)
        mood = try container.decode(Int.self, forKey: .mood)
        notes = try container.decode(String.self, forKey: .notes)
        flowerType = try container.decode(String.self, forKey: .flowerType)
        sleepHours = try container.decodeIfPresent(Double.self, forKey: .sleepHours) ?? 8.0
        steps = try container.decodeIfPresent(Int.self, forKey: .steps) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(mood, forKey: .mood)
        try container.encode(notes, forKey: .notes)
        try container.encode(flowerType, forKey: .flowerType)
        try container.encode(sleepHours, forKey: .sleepHours)
        try container.encode(steps, forKey: .steps)
    }
}

struct MoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var mood: Int
}
