//
//  MainTabView.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showCreateListing = false

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Label("tab.feed", systemImage: "house.fill")
                }
                .tag(0)

            MapView()
                .tabItem {
                    Label("tab.map", systemImage: "map.fill")
                }
                .tag(1)

            // Center tab — tapping immediately opens the create sheet
            Color.clear
                .tabItem {
                    Label("tab.share", systemImage: "plus.circle.fill")
                }
                .tag(2)

            ConversationListView()
                .tabItem {
                    Label("tab.messages", systemImage: "message.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("tab.profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.psAccent)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 2 {
                PSHaptics.medium()
                showCreateListing = true
                selectedTab = 0
            } else {
                PSHaptics.selection()
            }
        }
        .sheet(isPresented: $showCreateListing) {
            CreateListingView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
