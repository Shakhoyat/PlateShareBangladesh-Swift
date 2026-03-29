//
//  LanguageManager.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import SwiftUI

/// Manages the app's active locale. Stored in UserDefaults and applied
/// via `.environment(\.locale, ...)` so every SwiftUI String key auto-resolves.
@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var locale: Locale

    private let key = AppConstants.UserDefaultsKeys.preferredLanguageKey

    private init() {
        let saved = UserDefaults.standard.string(forKey: AppConstants.UserDefaultsKeys.preferredLanguageKey)
            ?? AppConstants.Languages.english
        self.locale = Locale(identifier: saved)
    }

    func setLanguage(_ code: String) {
        UserDefaults.standard.set(code, forKey: key)
        locale = Locale(identifier: code)
    }

    var currentCode: String {
        locale.identifier.prefix(2).lowercased() == "bn"
            ? AppConstants.Languages.bangla
            : AppConstants.Languages.english
    }
}
