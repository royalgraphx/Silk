//
//  ThemePreference.swift
//  Silk
//
//  Created by RoyalGraphX on 5/23/23.
//

import SwiftUI

class ThemePreference: ObservableObject {
    @Published var isDarkModeEnabled: Bool {
        didSet {
            updateTheme()
        }
    }

    init() {
        self.isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        updateTheme()
    }

    private func updateTheme() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.overrideUserInterfaceStyle = isDarkModeEnabled ? .dark : .light
        }
        UserDefaults.standard.set(isDarkModeEnabled, forKey: "isDarkModeEnabled")
    }
}
