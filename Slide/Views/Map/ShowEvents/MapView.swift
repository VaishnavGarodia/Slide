//
//  MapView.swift
//  Slide
//
//  Created by Vaishnav Garodia on 7/26/23.
//

import CoreLocation
import FirebaseFirestore
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator(parent1: self)
    }
    
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var source: CLLocationCoordinate2D!
    @State var destination: CLLocationCoordinate2D!
    @State var distance = ""
    @State var time = ""
    
    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator
        manager.delegate = context.coordinator
        map.showsUserLocation = true
        // get events from firebase and show them
        fetchEvents()
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func fetchEvents() {
        let db = Firestore.firestore()
        db.collection("Events")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                for document in documents {
                    print(document.data())
                    let data = document.data()
                    let eventName = data["eventName"]
                    let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    map.addAnnotation(annotation)
                    print("eventName", eventName ?? "?")
                    print("lat", location.latitude)
                    print("long", location.longitude)
                }
            }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapView
        
        init(parent1: MapView) {
            parent = parent1
        }

//        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//            if status == .denied {
//                parent.alert.toggle()
//            } else {
//                parent.manager.startUpdatingLocation()
//                if let location = parent.manager.location?.coordinate {
//                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
//                    let region = MKCoordinateRegion(center: location, span: span)
//                    parent.map.setRegion(region, animated: true)
//                }
//            }
//        }
    }
}
