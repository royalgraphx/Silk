//
//  SilkApp.swift
//  Silk
//
//  Created by RoyalGraphX on 5/23/23.
//

import SwiftUI

@main
struct SilkApp: App {
    @Environment(\.scenePhase) var scenePhase

    @StateObject var themePreference = ThemePreference()
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .environmentObject(themePreference)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                themePreference.isDarkModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark
            }
        }
    }
}
