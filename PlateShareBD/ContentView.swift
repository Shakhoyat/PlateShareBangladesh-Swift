//
//  ContentView.swift
//  PlateShareBD
//
//  Created by Himel on 25/2/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .unauthenticated:
                WelcomeView()
            case .authenticating:
                LoadingView(message: "Verifying...")
            case .needsProfileSetup:
                ProfileSetupView()
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: authViewModel.authState)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
