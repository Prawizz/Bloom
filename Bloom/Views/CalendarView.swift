import SwiftUI

struct CalendarView: View {
    @State private var currentMonth: Int
    @State private var currentYear: Int
    @Environment(JournalViewModel.self) var journalViewModel

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        return cal
    }()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    init() {
        let today = Date()
        let cal = Calendar(identifier: .gregorian)
        _currentMonth = State(initialValue: cal.component(.month, from: today))
        _currentYear = State(initialValue: cal.component(.year, from: today))
    }

    var body: some View {
        VStack(spacing: 20) {
            header
                .padding(.top, 10)
            
            // Weekday Labels
            HStack(spacing: 0) {
                ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.custom("DarumadropOne-Regular", size: 20))
                        .padding(.vertical, 5)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                        .frame(maxWidth: .infinity)
                }
            }

            let monthDates = datesForMonth()

            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(monthDates.indices, id: \.self) { index in
                    if let date = monthDates[index] {
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

    // MARK: - Strict Replacement Logic
    @ViewBuilder
    private func dateCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        
        // We only consider it a record if an entry exists AND mood is set
        let entry = journalViewModel.entry(for: date)
        let hasValidEntry = entry != nil && (entry?.mood ?? 0 > 0)
        
        NavigationLink(destination: JournalView(entryDate: date)) {
            VStack {
                if hasValidEntry, let safeEntry = entry {
                    // --- PATH A: ENTRY EXISTS (REPLACE NUMBER) ---
                    ZStack {
                        // Show the background WITHOUT a number
                        Image("grass_base")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        // Show the flower on top of the plain background
                        Image("\(safeEntry.flowerType)_\(safeEntry.mood)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .offset(y: -5)
                    }
                } else {
                    // --- PATH B: NO ENTRY (SHOW NUMBER TILE) ---
                    // Because this is in an 'else', Path A is completely ignored.
                    Image("\(day)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
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

            Text("\(monthName()) \(currentYear > 2500 ? String(currentYear - 543) : String(currentYear))")
                .font(.custom("DarumadropOne-Regular", size: 28))
                .padding(.vertical, 5)
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

    // MARK: - Helpers
    private func monthName() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
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
}
