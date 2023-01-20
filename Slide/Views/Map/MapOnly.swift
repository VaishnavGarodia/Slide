//
//  MapPage.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapOnly: UIViewRepresentable {
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
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
