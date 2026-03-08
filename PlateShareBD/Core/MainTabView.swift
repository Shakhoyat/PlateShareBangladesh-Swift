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
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "house.fill")
                    }
                    .tag(0)

                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(1)

                // Placeholder for center FAB
                Color.clear
                    .tabItem {
                        Label("Share", systemImage: "plus.circle.fill")
                    }
                    .tag(2)

                ConversationListView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(3)

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(4)
            }
            .tint(.psGreen)

            // Floating center button
            Button {
                showCreateListing = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.psGreen, .psGreenDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: .psGreen.opacity(0.4), radius: 8, x: 0, y: 4)

                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -20)
        }
        .sheet(isPresented: $showCreateListing) {
            CreateListingView()
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 2 {
                showCreateListing = true
                selectedTab = 0 // Reset to feed
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
