//
//  MapPage.swift
//  Slide
//
//  Created by Vaishnav Garodia
//

import CoreLocation
import MapKit
import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct MapWithEvents: UIViewRepresentable {
    let mapView = MKMapView()
    let locationSearchView = LocationSearchView()
    let locationSearchViewModel = LocationSearchViewModel()
    let locationManager = CLLocationManager()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true
        print("map with events initialized")
        // Retrieve events from Firebase
        let db = Firestore.firestore()
        db.collection("Events").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print(document.data())
                    let data = document.data()
                    let eventName = data["eventName"]
                    let location = data["location"] as? GeoPoint
                    let latitude = location?.latitude ?? 0.0
                    let longitude = location?.longitude ?? 0.0
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    mapView.addAnnotation(annotation)
                    print("eventName", eventName ?? "?")
                    print("lat", location?.latitude ?? 0.0)
                    print("long", location?.longitude ?? 0.0)
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
    
    func placePicked(response:MKLocalSearch.Response){
        for item in response.mapItems {
            print(item.phoneNumber ?? "No phone number.")
        }
    }
    
}

struct MapWithEvents_Previews: PreviewProvider {
    static var previews: some View {
        MapWithEvents()
            .ignoresSafeArea()
    }
}
