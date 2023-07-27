//
//  MapPage.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import CoreLocation
import MapKit
import SwiftUI

struct MapOnly: UIViewRepresentable {
    let configuration: MKStandardMapConfiguration
    let mapView = MKMapView()

    init() {
        configuration = MKStandardMapConfiguration()
        configuration.pointOfInterestFilter = MKPointOfInterestFilter(including: [])
    }

    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.preferredConfiguration = configuration
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let locationManager = CLLocationManager()
        locationManager.startUpdatingLocation()
        if let location = locationManager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}

struct MapOnly_Previews: PreviewProvider {
    static var previews: some View {
        MapOnly()
            .ignoresSafeArea()
    }
}
