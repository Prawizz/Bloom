import SwiftUI

struct CalendarView: View {
    @State private var currentMonth: Int
    @State private var currentYear: Int
    @EnvironmentObject var journalViewModel: JournalViewModel

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    init() {
        let today = Date()
        _currentMonth = State(initialValue: calendar.component(.month, from: today))
        _currentYear = State(initialValue: calendar.component(.year, from: today))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                header

                HStack(spacing: 4) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \ .self) { weekday in
                        Text(weekday)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(datesForMonth().indices, id: \ .self) { index in
                        let maybeDate = datesForMonth()[index]

                        if let date = maybeDate {
                            NavigationLink(destination: JournalView(entryDate: date)) {
                                ZStack {
                                    Circle()
                                        .fill(isToday(date) ? Color.blue.opacity(0.25) : Color.gray.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    
                                    if let entry = journalViewModel.entry(for: date) {
                                        Text(flowerEmoji(for: entry.flowerType, mood: entry.mood))
                                            .font(.title)
                                    } else {
                                        Text(dayNumber(from: date))
                                            .foregroundColor(calendar.isDate(date, equalTo: firstOfMonth(), toGranularity: .month) ? .primary : .secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear
                                .frame(width: 44, height: 44)
                        }
                    }
                }
                .animation(.easeInOut, value: currentMonth)

                Spacer()
            }
            .padding()
            .navigationTitle("Calendar")
        }
    }

    private var header: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .padding(8)
            }
            .buttonStyle(.bordered)

            Spacer()

            Text("\(monthName()) \(currentYear)")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .padding(8)
            }
            .buttonStyle(.bordered)
        }
    }

    private func monthName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.monthSymbols[currentMonth - 1]
    }

    private func firstOfMonth() -> Date {
        let components = DateComponents(year: currentYear, month: currentMonth, day: 1)
        return calendar.date(from: components) ?? Date()
    }

    private func datesForMonth() -> [Date?] {
        let firstDay = firstOfMonth()
        let weekday = calendar.component(.weekday, from: firstDay) // Sunday=1
        let dayOffset = weekday - 1

        guard let daysInMonth = calendar.range(of: .day, in: .month, for: firstDay)?.count else {
            return []
        }

        var result: [Date?] = Array(repeating: nil, count: dayOffset)

        for day in 1...daysInMonth {
            if let date = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: day)) {
                result.append(date)
            }
        }

        // Fill remaining cells to keep grid shape
        while result.count % 7 != 0 {
            result.append(nil)
        }

        return result
    }

    private func dayNumber(from date: Date) -> String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
    }

    private func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
    }

    private func flowerEmoji(for flowerType: String, mood: Int) -> String {
        let baseEmoji: String
        switch flowerType {
        case "rose": baseEmoji = "🌹"
        case "tulip": baseEmoji = "🌷"
        case "sunflower": baseEmoji = "🌻"
        case "daisy": baseEmoji = "🌼"
        case "lily": baseEmoji = "🌸"
        default: baseEmoji = "🌱"
        }
        
        // Vary witheredness: fresh for high mood, wilted for low
        switch mood {
        case 5: return baseEmoji  
        case 4: return baseEmoji
        case 3: return "🥀" 
        case 2: return "🥀"
        case 1: return "🥀"
        default: return baseEmoji
        }
    }

#Preview {
    CalendarView()
}
