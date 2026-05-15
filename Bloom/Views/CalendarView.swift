import SwiftUI

struct CalendarView: View {
    @State private var currentMonth: Int
    @State private var currentYear: Int
    @Environment(JournalViewModel.self) var journalViewModel

    private let calendar: Calendar = {
        var cal = Calendar.current
        // If you want to force Gregorian (2026) instead of Buddhist (2569),
        // uncomment the line below:
        // cal.identifier = .gregorian
        return cal
    }()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    init() {
        let today = Date()
        _currentMonth = State(initialValue: Calendar.current.component(.month, from: today))
        _currentYear = State(initialValue: Calendar.current.component(.year, from: today))
    }

    var body: some View {
        VStack(spacing: 20) {
            header
            
            // Weekday Labels
            HStack(spacing: 0) {
                ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.custom("DarumadropOne-Regular", size: 20))
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2)) // Brownish text
                        .frame(maxWidth: .infinity)
                    
                }
            }

            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(datesForMonth().indices, id: \.self) { index in
                    if let date = datesForMonth()[index] {
                        dateCell(for: date)
                    } else {
                        Color.clear.frame(height: 60)
                    }
                }
            }
            .animation(.easeInOut, value: currentMonth)

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Date Cell (The Image Part)
    @ViewBuilder
    private func dateCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        
        NavigationLink(destination: JournalView(entryDate: date)) {
            VStack {
                ZStack {
                    // 1. Your custom background image (1-31)
                    // Ensure your assets are named "1", "2", "3"...
                    Image("\(day)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                    // 2. Overlay the flower/emoji if an entry exists
                    if let entry = journalViewModel.entry(for: date) {
                        Text(flowerEmoji(for: entry.flowerType, mood: entry.mood))
                            .font(.system(size: 25))
                            .offset(y: -5) // Adjust based on your image design
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
            }

            Spacer()

            // FIX: Removed comma from year
            Text("\(monthName()) \(String(currentYear))")
                .font(.custom("DarumadropOne-Regular", size: 28))
                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers (Keep your existing helper functions below)
    private func monthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.monthSymbols[currentMonth - 1]
    }

    private func firstOfMonth() -> Date {
        let components = DateComponents(year: currentYear, month: currentMonth, day: 1)
        return calendar.date(from: components) ?? Date()
    }

    private func datesForMonth() -> [Date?] {
        let firstDay = firstOfMonth()
        let weekday = calendar.component(.weekday, from: firstDay)
        let dayOffset = weekday - 1
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: firstDay)?.count else { return [] }
        var result: [Date?] = Array(repeating: nil, count: dayOffset)
        for day in 1...daysInMonth {
            if let date = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: day)) {
                result.append(date)
            }
        }
        while result.count % 7 != 0 { result.append(nil) }
        return result
    }

    private func previousMonth() {
        if currentMonth == 1 { currentMonth = 12; currentYear -= 1 }
        else { currentMonth -= 1 }
    }

    private func nextMonth() {
        if currentMonth == 12 { currentMonth = 1; currentYear += 1 }
        else { currentMonth += 1 }
    }
    
    private func flowerEmoji(for flowerType: String, mood: Int) -> String {
        // Your existing emoji logic...
        let baseEmoji = flowerType == "rose" ? "🌹" : "🌱"
        return mood >= 4 ? baseEmoji : "🥀"
    }
}
