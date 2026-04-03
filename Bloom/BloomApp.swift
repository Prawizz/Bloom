//
//  BloomApp.swift
//  Bloom
//
//  Created by ปวิตร อัครวนิชกุล on 3/4/2569 BE.
//

import SwiftUI

@main
struct BloomApp: App {
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.systemBackground
        
        // Selected (soft pink)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(
            red: 0.95, green: 0.6, blue: 0.7, alpha: 1
        )
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(
                red: 0.95, green: 0.6, blue: 0.7, alpha: 1
            )
        ]
        
        // Unselected (soft gray)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        // subtle shadow
        appearance.shadowColor = UIColor.lightGray.withAlphaComponent(0.2)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .tint(Color(red: 0.95, green: 0.6, blue: 0.7)) // 🌸 pink
        }
    }
}
