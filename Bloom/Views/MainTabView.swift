//
//  MainTabView.swift
//  Bloom
//
//  Created by ปวิตร อัครวนิชกุล on 3/4/2569 BE.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) { 
            
            // Content
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
                    ProfileView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 👇 Tab bar pinned to bottom
            CustomNavBar(selectedTab: $selectedTab)
                .padding(.horizontal)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    MainTabView()
}
