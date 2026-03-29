//
//  PlateShareBDApp.swift
//  PlateShareBD
//
//  Created by Himel on 25/2/26.
//

import SwiftUI
import FirebaseCore

@main
struct PlateShareBDApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var languageManager = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(languageManager)
                .environment(\.locale, languageManager.locale)
        }
    }
}
