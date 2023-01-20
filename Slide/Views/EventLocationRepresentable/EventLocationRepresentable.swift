//
//  SwiftUIView.swift
//  Slide
//
//  Created by Thomas Shundi on 1/18/23.
//

import SwiftUI
import MapKit

struct EventLocationRepresentable: UIViewRepresentable {
    
    let mapView = MKMapView()
    let locationManager = LocationManager()
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
            
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}

extension EventLocationRepresentable {
    
    class MapCoordinator: NSObject, MKMapViewDelegate {
        let parent: EventLocationRepresentable
        
        init(parent: EventLocationRepresentable) {
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            
            parent.mapView.setRegion(region, animated: true)
        }
    }
}

