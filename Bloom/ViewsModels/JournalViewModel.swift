import Foundation
import Observation
import FirebaseFirestore
import FirebaseAuth

@Observable
class JournalViewModel {
    var entries: [JournalEntry] = []

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    var recentEntries: [JournalEntry] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.date >= sevenDaysAgo }
    }

    init() {
        loadEntries()
    }

    func loadEntries() {
        guard let uid = userID else { return }

        Firestore.firestore().collection("users").document(uid).collection("journals")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.entries = docs.compactMap { try? $0.data(as: JournalEntry.self) }
            }
    }

    func addEntry(_ entry: JournalEntry) {
        guard let uid = userID else { return }

        let day = Calendar.current.startOfDay(for: entry.date)
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: day) }
        entries.append(entry)

        try? Firestore.firestore().collection("users").document(uid)
            .collection("journals").document(entry.id)
            .setData(from: entry)
    }

    func deleteEntry(_ entry: JournalEntry) {
        guard let uid = userID else { return }

        Firestore.firestore().collection("users").document(uid)
            .collection("journals").document(entry.id)
            .delete()

        entries.removeAll { $0.id == entry.id }
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
}
