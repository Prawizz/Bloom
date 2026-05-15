import SwiftUI

struct MainTabView: View {
    
    var onSignOut: () -> Void = {}
    @State private var selectedPage = 0
    @State private var showProfile = false
    @Environment(MoodViewModel.self) var moodViewModel
    @Environment(JournalViewModel.self) var journalViewModel
    
    private let pageTitles = ["Garden", "Therapist Room"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("calendar_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(selectedPage == 0 ? 1 : 0)
                
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .opacity(selectedPage == 1 ? 1 : 0)
                
                // Content Layout
                VStack(spacing: 0) {
                    
                    pagePicker
                    
                    TabView(selection: $selectedPage) {
                        CalendarView()
                            .tag(0)
                        
                        AnalysisView()
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    // 2. Allow the internal TabView gesture animation to drive the state smoothly
                }
                .padding(.top, 50) // Tweaked slightly to prevent clashing with navigation bar
            }
            // 3. Animate title transitions seamlessly
            .navigationTitle(pageTitles[selectedPage])
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.3), value: selectedPage)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView(onSignOut: {
                    showProfile = false
                    onSignOut()
                })
            }
        }
        .onAppear {
            moodViewModel.loadMoods()
            journalViewModel.loadEntries()
        }
    }
    
    private var pagePicker: some View {
        HStack(spacing: 12) {
            ForEach(0..<pageTitles.count, id: \.self) { index in
                Button {
                    // 4. Clean up the spring animation for a responsive tap feel
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selectedPage = index
                    }
                } label: {
                    Text(pageTitles[index])
                        .font(.subheadline).bold()
                        .foregroundColor(selectedPage == index ? .white : .primary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(selectedPage == index ? Color("SoftPink") : Color(.systemGray5))
                        )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
}
