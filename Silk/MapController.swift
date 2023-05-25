//
//  MapController.swift
//  Silk
//
//  Created by RoyalGraphX on 5/23/23.
//  Assisted by ChatGPT
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

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
            Spacer()
            
            MapView()
                .edgesIgnoringSafeArea(.all)
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MapView: UIViewRepresentable {
    @State private var region = MKCoordinateRegion()
    private let locationManager = CLLocationManager()

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        setupLocationManager(with: context)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
    }

    func setupLocationManager(with context: Context) {
        locationManager.delegate = context.coordinator
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Request permission
        locationManager.requestWhenInUseAuthorization()

        // Start updating location when authorization status changes
        locationManager.startUpdatingLocation()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
            super.init()
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                parent.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                // Handle denied or restricted authorization
                break
            case .notDetermined:
                // Handle not determined authorization
                break
            @unknown default:
                break
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                print("Received location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // Adjust the values to control the zoom level
                parent.region = MKCoordinateRegion(center: location.coordinate, span: span)
                parent.locationManager.stopUpdatingLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location manager error: \(error.localizedDescription)")
        }
    }
}
