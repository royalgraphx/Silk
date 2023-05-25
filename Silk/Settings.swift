//
//  Settings.swift
//  Silk
//
//  Created by RoyalGraphX on 5/23/23.
//

import SwiftUI

struct Settings: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themePreference: ThemePreference
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $themePreference.isDarkModeEnabled) {
                        Text("Dark Mode")
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle(isOn: .constant(false)) {
                        Text("Push Notifications")
                    }
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        // Handle account settings action
                    }) {
                        Text("Account Settings")
                    }
                    
                    Button(action: {
                        // Handle privacy settings action
                    }) {
                        Text("Privacy Settings")
                    }
                }
                
                Section(header: Text("Support")) {
                    Button(action: {
                        // Handle help center action
                    }) {
                        Text("Help Center")
                    }
                    
                    Button(action: {
                        // Handle contact support action
                    }) {
                        Text("Contact Support")
                    }
                }
                
                Section(footer: Text("© 2023 Silk Development. All Rights Reserved.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
        }
    }
}
