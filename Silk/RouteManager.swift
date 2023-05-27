//
//  RouteManager.swift
//  Silk
//
//  Created by RoyalGraphX on 5/25/23.
//

import Foundation
import MapKit
import CoreLocation

class RouteManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var routes: [MKRoute] = []
    @Published var location: CLLocation?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.location = location
            }
        }
    }

    func clearRoutes() {
        routes.removeAll()
    }

    func routeBetweenAddresses(addresses: [String]) {
        guard addresses.count >= 2 else {
            print("Insufficient addresses provided.")
            return
        }
        
        // Clear existing routes
        clearRoutes()

        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(addresses[0]) { [weak self] (sourcePlacemarks, sourceError) in
            guard let self = self else { return }
            if let sourceError = sourceError {
                print("Geocoding error for first address: \(sourceError)")
                return
            }
            
            if let sourcePlacemark = sourcePlacemarks?.first {
                self.route(sourcePlacemark: sourcePlacemark, toAddresses: Array(addresses[1...]))
            }
        }
    }

    private func route(sourcePlacemark: CLPlacemark, toAddresses addresses: [String]) {
        let geocoder = CLGeocoder()
        
        for (index, address) in addresses.enumerated() {
            geocoder.geocodeAddressString(address) { [weak self] (destinationPlacemarks, destinationError) in
                guard let self = self else { return }
                if let destinationError = destinationError {
                    print("Geocoding error for destination address: \(destinationError)")
                    return
                }
                
                if let destinationPlacemark = destinationPlacemarks?.first {
                    self.calculateDirections(sourcePlacemark: sourcePlacemark, destinationPlacemark: destinationPlacemark)
                    if index < addresses.count - 1 {
                        self.route(sourcePlacemark: destinationPlacemark, toAddresses: Array(addresses[(index+1)...]))
                    }
                }
            }
        }
    }

    private func calculateDirections(sourcePlacemark: CLPlacemark, destinationPlacemark: CLPlacemark) {
        let source = MKMapItem(placemark: MKPlacemark(placemark: sourcePlacemark))
        let destination = MKMapItem(placemark: MKPlacemark(placemark: destinationPlacemark))
        
        let request = MKDirections.Request()
        request.source = source
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
                DispatchQueue.main.async {
                    self.routes.append(route)
                }
            }
        }
    }
}
