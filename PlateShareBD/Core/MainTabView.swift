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
    @State private var fabPressed = false

    var body: some View {
        ZStack(alignment: .bottom) {
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

                // Placeholder for center FAB
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

            // Floating action button
            Button {
                PSHaptics.medium()
                showCreateListing = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.psAccent, .psAccentDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: .psAccent.opacity(fabPressed ? 0.2 : 0.4),
                            radius: fabPressed ? 4 : 8,
                            x: 0, y: fabPressed ? 2 : 4
                        )

                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.white)
                }
                .scaleEffect(fabPressed ? 0.92 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: fabPressed)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if !fabPressed { fabPressed = true } }
                    .onEnded { _ in fabPressed = false }
            )
            .offset(y: -20)
            .accessibilityLabel("Share food listing")
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
