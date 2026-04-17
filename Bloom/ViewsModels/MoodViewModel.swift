import Foundation
import Observation

@Observable
class MoodViewModel {
    var moods: [MoodEntry] = []
    
    private let key = "saved_moods"
    
    init() {
        loadMoods()
    }
    
    func setMood(_ mood: Int, for date: Date = Date()) {
        let day = Calendar.current.startOfDay(for: date)
        
        moods.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: day)
        }
        
        moods.append(MoodEntry(date: day, mood: mood))
        saveMoods()
    }
    
    func mood(for date: Date = Date()) -> Int? {
        let day = Calendar.current.startOfDay(for: date)
        return moods.first {
            Calendar.current.isDate($0.date, inSameDayAs: day)
        }?.mood
    }
    
    func hasMood(for date: Date) -> Bool {
        mood(for: date) != nil
    }
    
    // Save
    private func saveMoods() {
        if let data = try? JSONEncoder().encode(moods) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // Load
    private func loadMoods() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            moods = decoded
        }
    }
    
    var sortedMoods: [MoodEntry] {
        moods.sorted { $0.date < $1.date }
    }

    var recentMoods: [MoodEntry] {
        Array(sortedMoods.suffix(7))
    }
}

