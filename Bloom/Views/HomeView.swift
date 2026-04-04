import SwiftUI

struct HomeView: View {

    @StateObject var vm = MoodViewModel()
    @State private var selectedDate = Date()
    @State private var showCalendar = false

    let moods: [(emoji: String, label: String, color: Color)] = [
        ("😢", "Sad",     Color(red: 0.55, green: 0.72, blue: 0.95)),
        ("😐", "Meh",     Color(red: 0.85, green: 0.78, blue: 0.95)),
        ("😊", "Good",    Color(red: 0.95, green: 0.85, blue: 0.65)),
        ("😄", "Happy",   Color(red: 0.95, green: 0.72, blue: 0.60)),
        ("😍", "Amazing", Color(red: 0.95, green: 0.65, blue: 0.78)),
    ]

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Good night"
        }
    }

    var selectedMood: Int? { vm.mood(for: selectedDate) }

    var selectedColor: Color {
        guard let idx = selectedMood else {
            return Color(red: 0.95, green: 0.82, blue: 0.86)
        }
        return moods[idx].color
    }

    var dateLabel: String {
        if isToday { return "Today" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [
                    selectedColor.opacity(0.35),
                    Color(red: 0.99, green: 0.97, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: selectedMood)

            GeometryReader { geo in
                Circle()
                    .fill(selectedColor.opacity(0.18))
                    .frame(width: 260, height: 260)
                    .offset(x: -60, y: -40)
                    .blur(radius: 40)
                    .animation(.easeInOut(duration: 0.8), value: selectedMood)

                Circle()
                    .fill(selectedColor.opacity(0.12))
                    .frame(width: 200, height: 200)
                    .offset(x: geo.size.width - 100, y: geo.size.height - 160)
                    .blur(radius: 50)
                    .animation(.easeInOut(duration: 0.8), value: selectedMood)
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isToday ? greeting + " ☀️" : "Looking back")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        Text("How are\nyou feeling?")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.18, green: 0.14, blue: 0.20))
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.top, 60)
                    .padding(.bottom, 28)

                    //Date Selector
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCalendar.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13, weight: .semibold))
                            Text(dateLabel)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                            Image(systemName: showCalendar ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(selectedColor.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(selectedColor.opacity(0.15))
                        )
                    }
                    .padding(.bottom, 16)

                    // Calendar
                    if showCalendar {
                        VStack(spacing: 0) {
                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .tint(selectedColor)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(red: 0.95, green: 0.65, blue: 0.78).opacity(0.5))
                                    .frame(width: 8, height: 8)
                                Text("Mood recorded")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.bottom, 12)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.white.opacity(0.75))
                                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Mood buttons
                    HStack(spacing: 10) {
                        ForEach(0..<moods.count, id: \.self) { index in
                            MoodButton(
                                emoji: moods[index].emoji,
                                label: moods[index].label,
                                color: moods[index].color,
                                isSelected: selectedMood == index
                            ) {
                                vm.setMood(index, for: selectedDate)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Mood Banner
                    ZStack {
                        if let mood = selectedMood {
                            HStack(spacing: 12) {
                                Text(moods[mood].emoji)
                                    .font(.system(size: 28))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isToday ? "Today's mood" : dateLabel)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("Feeling \(moods[mood].label)")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0.18, green: 0.14, blue: 0.20))
                                }

                                Spacer()

                                Circle()
                                    .fill(moods[mood].color.opacity(0.3))
                                    .frame(width: 10, height: 10)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.white.opacity(0.75))
                                    .shadow(color: moods[mood].color.opacity(0.25), radius: 16, x: 0, y: 6)
                            )
                            .padding(.horizontal, 24)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: selectedMood)
                    .padding(.top, 32)

                    Spacer(minLength: 40)
                }
            }
        }
    }
}


struct MoodButton: View {
    let emoji: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.28) : Color.white.opacity(0.6))
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: isSelected ? color.opacity(0.4) : Color.black.opacity(0.06),
                            radius: isSelected ? 12 : 4,
                            x: 0,
                            y: isSelected ? 4 : 2
                        )

                    if isSelected {
                        Circle()
                            .strokeBorder(color.opacity(0.5), lineWidth: 2)
                            .frame(width: 56, height: 56)
                    }

                    Text(emoji)
                        .font(.system(size: 26))
                }
                .scaleEffect(isSelected ? 1.15 : 1.0)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? color.opacity(0.9) : Color.secondary.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
}
