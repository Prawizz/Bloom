import Foundation

class LLMService {
    
    static let shared = LLMService()
    
    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
    }
    
    // MAIN FUNCTION
    func analyze(moods: [MoodEntry], journals: [JournalEntry]) async throws -> String {
        
        // ✅ Limit to recent 7 days
        let recentMoods = moods.sorted { $0.date < $1.date }.suffix(7)
        
        // ✅ Format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        // ✅ Build summary
        let summary = recentMoods.map { mood -> String in
            
            let dateString = formatter.string(from: mood.date)
            
            let journalText = journals.first {
                Calendar.current.isDate($0.date, inSameDayAs: mood.date)
            }?.notes ?? "No journal entry"
            
            return """
            Date: \(dateString)
            Mood: \(mood.mood)/5
            Journal: \(journalText)
            """
            
        }.joined(separator: "\n\n")
        
        // ✅ Prompt
        let prompt = """
        You are a gentle and supportive wellness assistant in an app called Bloom.

        Here are the user's recent mood and journal entries:
        \(summary)

        Analyze:
        - mood trends over time
        - emotional patterns
        - possible causes

        Respond in:
        - 2-3 short sentences
        - warm and supportive tone
        - include ONE helpful suggestion
        - keep it simple and kind
        """
        
        // ✅ Request
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [[
                "parts": [["text": prompt]]
            ]]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // ✅ Call API
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // ✅ Check HTTP
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            
            let raw = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LLMError.apiError("HTTP \(httpResponse.statusCode): \(raw)")
        }
        
        // ✅ Parse response
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = json["candidates"] as? [[String: Any]],
            let first = candidates.first,
            let content = first["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            let raw = String(data: data, encoding: .utf8) ?? "Empty response"
            throw LLMError.parseError("Unexpected response: \(raw)")
        }
        
        return text
    }
}

// MARK: - Errors

enum LLMError: Error, LocalizedError {
    
    case apiError(String)
    case parseError(String)
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .apiError(let msg):
            return "API Error: \(msg)"
        case .parseError(let msg):
            return "Parse Error: \(msg)"
        case .missingAPIKey:
            return "Missing Gemini API Key"
        }
    }
}
