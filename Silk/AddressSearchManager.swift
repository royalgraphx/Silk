//
//  AddressSearchManager.swift
//  Silk
//
//  Created by RoyalGraphX on 5/24/23.
//

import SwiftUI
import MapKit

class AddressSearchManager: NSObject, ObservableObject {
    @Published var searchCompleter = MKLocalSearchCompleter()
    @Published var suggestions: [MKLocalSearchCompletion] = []
    @Published var selectedSuggestion: MKLocalSearchCompletion? // Add selectedSuggestion property

    override init() {
        super.init()
        searchCompleter.delegate = self
    }
}

extension AddressSearchManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle error
    }
}
