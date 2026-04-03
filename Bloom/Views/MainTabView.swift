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
            
            JournalView(entryDate: Date())
                .tabItem {
                    Image(systemName: "pencil.and.list.clipboard")
                    Text("Journal")
                }
            
            AnalysisView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Analysis")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    MainTabView()
}
