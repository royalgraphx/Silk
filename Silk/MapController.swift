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

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        // Remove old route overlays
        view.removeOverlays(view.overlays)

        // Add the new route overlays
        for route in routeManager.routes {
            view.addOverlay(route.polyline, level: .aboveRoads)
        }

        // Remove old markers
        view.removeAnnotations(view.annotations)

        // Add new markers
        let addresses = routeManager.addresses
        for (index, address) in addresses.enumerated() {
            geocodeAddress(address) { placemark in
                if let placemark = placemark {
                    let marker = MKPointAnnotation()
                    marker.coordinate = placemark.location!.coordinate
                    marker.title = "Stop \(index + 0)"
                    view.addAnnotation(marker)
                }
            }
        }

        // Zoom the map to fit all route overlays and markers
        if let firstRoute = routeManager.routes.first {
            var boundingMapRect = firstRoute.polyline.boundingMapRect
            for route in routeManager.routes.dropFirst() {
                boundingMapRect = boundingMapRect.union(route.polyline.boundingMapRect)
            }
            for address in addresses {
                geocodeAddress(address) { placemark in
                    if let location = placemark?.location {
                        let mapPoint = MKMapPoint(location.coordinate)
                        let mapRect = MKMapRect(origin: mapPoint, size: MKMapSize(width: 0, height: 0))
                        boundingMapRect = boundingMapRect.union(mapRect)
                    }
                }
            }
            view.setVisibleMapRect(boundingMapRect, edgePadding: UIEdgeInsets(top: 70.0, left: 40.0, bottom: 50.0, right: 20.0), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func geocodeAddress(_ address: String, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first {
                completion(placemark)
            } else {
                completion(nil)
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else {
                return nil
            }

            let identifier = "marker"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }

            // Customize the marker view
            annotationView?.markerTintColor = .darkGray

            return annotationView
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 3
            return renderer
        }
    }
}
