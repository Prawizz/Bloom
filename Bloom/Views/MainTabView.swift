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

            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
            JournalView()
                .tabItem {
                    Image(systemName: "pencil.and.list.clipboard")
                    Text("journal")
                }
            
            AnalysisView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Calendar")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Calendar")
                }
        }
    }
}

#Preview {
    MainTabView()
}
