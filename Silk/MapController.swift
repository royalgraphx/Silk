//
//  MapController.swift
//  Silk
//
//  Created by RoyalGraphX on 5/25/23.
//  Assisted by ChatGPT
//

import SwiftUI
import MapKit
import CoreLocation

struct MapController: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var routeManager: RouteManager

    var body: some View {
        VStack {
            
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            
            HStack {
                
                Text("Live Preview")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 16)
                    .padding(.leading, 16)

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                }
                .foregroundColor(.gray)
            }
            Spacer()
            MapView(routeManager: routeManager)
                .edgesIgnoringSafeArea(.all)
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct MapController_Previews: PreviewProvider {
    static var previews: some View {
        MapController(routeManager: RouteManager())
    }
}

struct MapView: UIViewRepresentable {
    @ObservedObject var routeManager: RouteManager
    private let locationManager = CLLocationManager()

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        setupLocationManager(with: context)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        // Reset the old route overlay
        if let oldRoute = context.coordinator.route {
            view.removeOverlay(oldRoute.polyline)
        }

        // Add the new route overlay
        if let route = routeManager.route {
            context.coordinator.route = route
            view.addOverlay(route.polyline, level: .aboveRoads)

            // Zoom the map to the route
            view.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 70.0, left: 40.0, bottom: 50.0, right: 20.0), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func setupLocationManager(with context: Context) {
        locationManager.delegate = context.coordinator
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapView
        var route: MKRoute?

        init(_ parent: MapView) {
            self.parent = parent
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.startUpdatingLocation()
            default:
                break
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                print("Received location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // Adjust the values to control the zoom level
                _ = MKCoordinateRegion(center: location.coordinate, span: span)
                parent.locationManager.stopUpdatingLocation()
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 3
            return renderer
        }
    }
}
