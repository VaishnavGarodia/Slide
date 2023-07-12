//
//  MapPage.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import CoreLocation
import MapKit
import SwiftUI
import Firebase
import FirebaseFirestore

struct MapWithEvents: UIViewRepresentable {
    let mapView = MKMapView()
    let locationManager = CLLocationManager()

    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true
        print("map with events initialized")
        // Retrieve events from Firebase
        let eventsRef = Firestore.firestore().collection("Events")
        eventsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting events: \(error.localizedDescription)")
                return
            }
            
            // Loop through each event and create an annotation
            if let documents = snapshot?.documents {
                for document in documents {
                    let data = document.data()
                    if let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double {
                        print("latitude", latitude)
                        print("longitude", longitude)
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if let location = locationManager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}

struct MapWithEvents_Previews: PreviewProvider {
    static var previews: some View {
        MapWithEvents()
            .ignoresSafeArea()
    }
}
