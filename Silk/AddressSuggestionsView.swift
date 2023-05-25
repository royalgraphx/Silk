//
//  AddressSuggestionsView.swift
//  Silk
//
//  Created by RoyalGraphX on 5/24/23.
//

import SwiftUI
import MapKit

struct AddressSuggestionsView: View {
    @ObservedObject var addressSearchManager: AddressSearchManager
    @Binding var textFieldText: String // Add this line
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if !addressSearchManager.suggestions.isEmpty && !textFieldText.isEmpty { // Check if suggestions and text field are not empty
            VStack(alignment: .leading, spacing: 0) {
                ForEach(addressSearchManager.suggestions, id: \.self) { suggestion in
                    Button(action: {
                        withAnimation {
                            textFieldText = suggestion.title // Update the text field text
                            addressSearchManager.suggestions = [] // Clear the suggestions after selecting one
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(suggestion.title)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.body)
                                
                                Text(suggestion.subtitle)
                                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 12)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if suggestion != addressSearchManager.suggestions.last {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.5))
            .cornerRadius(8)
            .padding(.top, 8)
            .onDisappear {
                if textFieldText.isEmpty {
                    addressSearchManager.suggestions = [] // Clear the suggestions when the view disappears and the text field is empty
                }
            }
        } else {
            EmptyView() // Display nothing if there are no suggestions or the text field is empty
        }
    }
}
