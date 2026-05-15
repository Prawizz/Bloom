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
                // 1. Garden Background
                Image("calendar_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(selectedPage == 0 ? 1 : 0)
                
                // 2. Therapist Room Background
                Image("analysis_background")
                    .resizable()
                    .scaledToFill()
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
                }
                .padding(.top, 50)
            }
            .navigationTitle(pageTitles[selectedPage])
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.3), value: selectedPage)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        // --- CUSTOM USER LOGO ---
                        Image("user_logo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 35) // Perfect size for a top bar
                            .clipShape(Circle()) // Makes it circular
                            .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Adds a clean white border
                            .shadow(radius: 3)
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
                                .fill(selectedPage == index ? Color.brown : Color(.systemGray5))
                        )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
}
