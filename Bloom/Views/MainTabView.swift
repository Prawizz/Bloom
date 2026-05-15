import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    
    var onSignOut: () -> Void = {}
    @State private var selectedPage = 0
    @State private var showProfile = false
    
    // 👇 Local tracking ID that forces an instant layout refresh without network lag
    @State private var profileChangeID = UUID().uuidString
    
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
                    
                    // Unified Header Control
                    customHeaderBlock
                    
                    TabView(selection: $selectedPage) {
                        CalendarView()
                            .tag(0)
                        
                        AnalysisView()
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                // Keeps content safely underneath the notch/status bar area
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .toolbar(.hidden, for: .navigationBar) // Completely disables the clashing native bar
            .sheet(isPresented: $showProfile, onDismiss: {
                // 👇 Refresh the local view ID the exact moment the sheet slides away
                profileChangeID = UUID().uuidString
            }) {
                ProfileView(onSignOut: {
                    showProfile = false
                    onSignOut()
                }) // 👈 Removed the extra parameter that was causing your compiler error
            }
        }
        .onAppear {
            moodViewModel.loadMoods()
            journalViewModel.loadEntries()
            profileChangeID = UUID().uuidString // Ensure local verification on launch
        }
    }
    
    // Custom Header
    private var customHeaderBlock: some View {
        HStack(alignment: .center, spacing: 12) {
            
            // Integrated Page Picker Layout
            HStack(spacing: 8) {
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
                                    .fill(selectedPage == index ? Color.brown : Color(.systemGray5).opacity(0.8))
                            )
                    }
                }
            }
            
            // Profile Button (Now loads 100% locally with zero latency)
            Button {
                showProfile = true
            } label: {
                Group {
                    if let localImage = ProfileImageManager.loadLocalImage() {
                        localImage
                            .resizable()
                            .scaledToFill()
                    } else {
                        // Standard fallback asset if no custom avatar photo on disk exists
                        Image("user_logo")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            }
            .id(profileChangeID) // 👈 Tells SwiftUI to explicitly redraw this layout block when id shifts
        }
        .padding(.horizontal)
        // --- ADJUST THIS PADDING TO SHIFT IT DOWN ---
        // 15-20pt is usually the sweet spot below the system status bar.
        .padding(.top, 50)
        .padding(.bottom, 12)
    }
}
