import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct BloomApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var journalViewModel = JournalViewModel()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.systemBackground
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(
            red: 0.95, green: 0.6, blue: 0.7, alpha: 1
        )
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(
                red: 0.95, green: 0.6, blue: 0.7, alpha: 1
            )
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        appearance.shadowColor = UIColor.lightGray.withAlphaComponent(0.2)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(journalViewModel)
        }
    }
}

#Preview{
    LoginView()
}
