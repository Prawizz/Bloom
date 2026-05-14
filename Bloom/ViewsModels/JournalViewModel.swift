import Foundation
import Observation
import FirebaseFirestore
import FirebaseAuth

@Observable
class JournalViewModel {
    var entries: [JournalEntry] = []
    var errorMessage: String?
    private var listener: ListenerRegistration?

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

    deinit {
        listener?.remove()
    }

    func loadEntries() {
        guard let uid = userID else { return }
        listener?.remove()

        listener = Firestore.firestore().collection("users").document(uid).collection("journals")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let docs = snapshot?.documents else { return }
                self?.entries = docs.compactMap { try? $0.data(as: JournalEntry.self) }
            }
    }

    func addEntry(_ entry: JournalEntry) {
        guard let uid = userID else {
            errorMessage = "Unable to save entry: not signed in."
            return
        }

        let day = Calendar.current.startOfDay(for: entry.date)

        Firestore.firestore().collection("users").document(uid)
            .collection("journals").document(entry.id)
            .setData(from: entry) { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    self?.entries.append(entry)
                }
            }
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
