//
//  RouteManager.swift
//  Silk
//
//  Created by RoyalGraphX on 5/25/23.
//

import Foundation
import MapKit
import CoreLocation

class RouteManager: ObservableObject {
    @Published var route: MKRoute?

    func routeToFirstAddress(address: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }
            
            if let placemark = placemarks?.first {
                self.calculateDirections(destinationPlacemark: placemark)
            }
        }
    }
    
    private func calculateDirections(destinationPlacemark: CLPlacemark) {
        let destination = MKMapItem(placemark: MKPlacemark(placemark: destinationPlacemark))
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            if let error = error {
                print("Directions error: \(error)")
                return
            }
            
            if let route = response?.routes.first {
                self.route = route
            }
        }
    }
}
