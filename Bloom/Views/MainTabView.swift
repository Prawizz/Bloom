import SwiftUI

struct MainTabView: View {

    var onSignOut: () -> Void = {}
    @State private var selectedTab = 0
    @Environment(MoodViewModel.self) var moodViewModel
    @Environment(JournalViewModel.self) var journalViewModel

    var body: some View {
        ZStack(alignment: .bottom) {

            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    CalendarView()
                case 2:
                    JournalView(entryDate: Date())
                case 3:
                    AnalysisView()
                case 4:
                    ProfileView(onSignOut: onSignOut)
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomNavBar(selectedTab: $selectedTab)
                .padding(.horizontal)
                .padding(.bottom, 10)
        }
        .onAppear {
            moodViewModel.loadMoods()
            journalViewModel.loadEntries()
        }
    }
}

#Preview {
    MainTabView()
}
