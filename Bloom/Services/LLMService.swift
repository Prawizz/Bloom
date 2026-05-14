import Foundation

class LLMService {

    static let shared = LLMService()

    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "GROQ_API_KEY") as? String ?? ""
    }
    private let model = "llama-3.3-70b-versatile"

    func analyze(moods: [MoodEntry], journals: [JournalEntry]) async throws -> String {

        print("🔑 API Key empty: \(apiKey.isEmpty)")
        print("📊 Moods count: \(moods.count)")
        print("📓 Journals count: \(journals.count)")

        let recentMoods = moods.sorted { $0.date < $1.date }.suffix(7)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let summary = recentMoods.map { mood -> String in
            let dateString = formatter.string(from: mood.date)

            let journalEntry = journals.first {
                Calendar.current.isDate($0.date, inSameDayAs: mood.date)
            }

            let sleepHours = journalEntry?.sleepHours ?? 0.0
            let steps = journalEntry?.steps ?? 0
            let journalText = journalEntry?.notes ?? "No journal entry"

            return """
            Date: \(dateString)
            Mood: \(mood.mood)/5
            Sleep: \(sleepHours) hrs
            Steps: \(steps)
            Journal: \(journalText)
            """
        }.joined(separator: "\n\n")

        print("📝 Summary empty: \(summary.isEmpty)")

        let prompt = """
        You are a gentle and supportive wellness assistant in an app called Bloom.

        Here are the user's recent mood, sleep, activity, and journal entries:
        \(summary)

        Analyze:
        - mood trends over time
        - emotional patterns from notes
        - possible causes or correlations
        - sleep patterns and quality
        - physical activity levels (steps)

        Respond in:
        - 3-4 short sentences
        - warm and supportive tone
        - include ONE helpful suggestion
        - keep it simple and kind
        """

        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 300,
            "temperature": 0.7
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("📡 Sending request to Groq...")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("📬 HTTP Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                let raw = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Error: \(raw)")
                throw LLMError.apiError("HTTP \(httpResponse.statusCode): \(raw)")
            }
        }

        let rawResponse = String(data: data, encoding: .utf8) ?? "Empty"
        print("✅ Raw response: \(rawResponse.prefix(200))")

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let first = choices.first,
            let message = first["message"] as? [String: Any],
            let text = message["content"] as? String
        else {
            let raw = String(data: data, encoding: .utf8) ?? "Empty response"
            print("❌ Parse Error: \(raw)")
            throw LLMError.parseError("Unexpected response: \(raw)")
        }

        print("🎉 Success!")
        return text
    }
}

enum LLMError: Error, LocalizedError {
    case apiError(String)
    case parseError(String)
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .apiError(let msg): return "API Error: \(msg)"
        case .parseError(let msg): return "Parse Error: \(msg)"
        case .missingAPIKey: return "Missing API Key"
        }
    }
}
