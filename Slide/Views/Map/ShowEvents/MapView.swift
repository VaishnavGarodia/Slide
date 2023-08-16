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

    @Binding var map: MKMapView
    @Binding var manager: CLLocationManager
    @Binding var alert: Bool
    @Binding var destination: CLLocationCoordinate2D!
    @Binding var show: Bool
    @Binding var events: [Event]
    @Binding var selectedEvent: Event
    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator
        manager.delegate = context.coordinator
        map.showsUserLocation = true
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapView

        init(parent1: MapView) {
            parent = parent1
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied {
                parent.alert.toggle()
            } else {
                parent.manager.startUpdatingLocation()
                if let location = parent.manager.location?.coordinate {
                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    let region = MKCoordinateRegion(center: location, span: span)
                    parent.map.setRegion(region, animated: true)
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // If the annotation isn't from a capital city, it must return nil so iOS uses a default view.
            guard annotation is Event else { return nil }

            // Define a reuse identifier. This is a string that will be used to ensure we reuse annotation views as much as possible.
            let identifier = "Event"

            // Try to dequeue an annotation view from the map view's pool of unused views.
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                // If it isn't able to find a reusable view, create a new one using
                // MKPinAnnotationView and sets its canShowCallout property to true. This
                // triggers the popup with the event name.
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                // Create a new UIButton using the built-in .detailDisclosure type. This is a small blue "i" symbol with a circle around it.
                let btn = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
            } else {
                // If it can reuse a view, update that view to use a different annotation.
                annotationView?.annotation = annotation
                    // Create a new UIButton using the built-in .detailDisclosure type. This is a small blue "i" symbol with a circle around it.
                    let btn = UIButton(type: .detailDisclosure)
                    annotationView?.rightCalloutAccessoryView = btn
                }
                else {
                    // If it can reuse a view, update that view to use a different annotation.
                    annotationView?.annotation = annotation
                }
            let eventData = annotation as! Event
            annotationView?.image = UIImage(systemName: eventData.icon)
            
            return annotationView

            }
            let eventData = annotation as! Event
            annotationView?.image = UIImage(systemName: eventData.icon)

            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let event = view.annotation as? Event else { return }
            parent.selectedEvent = event
        }
    }
}
