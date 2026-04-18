import Foundation
import Observation
import FirebaseFirestore
import FirebaseAuth

@Observable
class MoodViewModel {
    var moods: [MoodEntry] = []

    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    var recentMoods: [MoodEntry] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return moods.filter { $0.date >= sevenDaysAgo }
    }

    init() {
        loadMoods()
    }

    func loadMoods() {
        guard let uid = userID else { return }

        // ✅ Call Firestore.firestore() here, not as a property
        Firestore.firestore().collection("users").document(uid).collection("moods")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.moods = docs.compactMap { try? $0.data(as: MoodEntry.self) }
            }
    }

    func setMood(_ mood: Int, for date: Date = Date()) {
        guard let uid = userID else { return }

        let day = Calendar.current.startOfDay(for: date)
        moods.removeAll { Calendar.current.isDate($0.date, inSameDayAs: day) }

        let entry = MoodEntry(date: day, mood: mood)
        moods.append(entry)

        try? Firestore.firestore().collection("users").document(uid)
            .collection("moods").document(entry.id)
            .setData(from: entry)
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
}
