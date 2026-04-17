import Foundation
import Observation

@Observable
class JournalViewModel {

    var entries: [JournalEntry] = []

    private let key = "saved_entries"

    init() {
        loadEntries()
    }

    func addEntry(_ entry: JournalEntry) {
        let day = Calendar.current.startOfDay(for: entry.date)

        entries.removeAll {
            Calendar.current.isDate($0.date, inSameDayAs: day)
        }

        entries.append(entry)
        saveEntries()
    }

    func entry(for date: Date) -> JournalEntry? {
        let day = Calendar.current.startOfDay(for: date)
        return entries.first {
            Calendar.current.isDate($0.date, inSameDayAs: day)
        }
    }

    func hasEntry(for date: Date) -> Bool {
        entry(for: date) != nil
    }

    private func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
    
    var sortedEntries: [JournalEntry] {
        entries.sorted { $0.date < $1.date }
    }

    var recentEntries: [JournalEntry] {
        Array(sortedEntries.suffix(7))
    }
}
