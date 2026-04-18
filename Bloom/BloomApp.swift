import SwiftUI
import Firebase
import Observation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }
}

@main
struct BloomApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var moodViewModel: MoodViewModel
    @State private var journalViewModel: JournalViewModel

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        _moodViewModel = State(initialValue: MoodViewModel())
        _journalViewModel = State(initialValue: JournalViewModel())
        setupTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(moodViewModel)
                .environment(journalViewModel)
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(
            red: 0.95, green: 0.6, blue: 0.7, alpha: 1
        )
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.95, green: 0.6, blue: 0.7, alpha: 1)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        appearance.shadowColor = UIColor.lightGray.withAlphaComponent(0.2)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
