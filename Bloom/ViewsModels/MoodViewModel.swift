import Foundation

class JournalViewModel: ObservableObject {

    @Published var entries: [JournalEntry] = []

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

    //Save
    private func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    //Load
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
}
