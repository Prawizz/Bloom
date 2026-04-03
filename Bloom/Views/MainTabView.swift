//
//  MainTabView.swift
//  Bloom
//
//  Created by ปวิตร อัครวนิชกุล on 3/4/2569 BE.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            Text("Calendar")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
        }
    }
}

#Preview {
    MainTabView()
}
