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

struct CreateEventView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return CreateEventView.Coordinator(parent1: self)
    }
    
    @Binding var map: MKMapView
    @Binding var manager: CLLocationManager
    @Binding var alert: Bool
    @Binding var source: CLLocationCoordinate2D!
    @Binding var destination: CLLocationCoordinate2D!
    @Binding var event: Event
    @Binding var distance: String
    @Binding var time: String
    @Binding var show: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        self.map.delegate = context.coordinator
        self.manager.delegate = context.coordinator
        self.map.showsUserLocation = true
        if let location = self.manager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            self.map.setRegion(region, animated: true)
        }
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.tap(ges:)))
        self.map.addGestureRecognizer(gesture)
        return self.map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: CreateEventView
        
        init(parent1: CreateEventView) {
            self.parent = parent1
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied {
                self.parent.alert.toggle()
            }
            else {
                self.parent.manager.startUpdatingLocation()
                if let location = self.parent.manager.location?.coordinate {
                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.parent.map.setRegion(region, animated: true)
                }
            }
        }
        
        @objc func tap(ges: UITapGestureRecognizer) {
            // TOOD: Add a new box in the event creation view in this case asking for location name as that does not get updated correctly.
            let location = ges.location(in: self.parent.map)
            let mplocation = self.parent.map.convert(location, toCoordinateFrom: self.parent.map)
            
            var addressString = ""
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: mplocation, span: span)
            let point = MKPointAnnotation()
            point.subtitle = "Event location"
            point.coordinate = mplocation
            
            self.parent.destination = mplocation
            
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation(CLLocation(latitude: mplocation.latitude, longitude: mplocation.longitude)) { places, err in
                
                if err != nil {
                    print((err?.localizedDescription)!)
                    return
                }
                
                let pm = places! as [CLPlacemark]
                if pm.count > 0 {
                    let pm = places![0]
                    print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.subThoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.subThoroughfare != nil {
                        addressString = addressString + pm.subThoroughfare! + " "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }

                    print(addressString)
                }
                
                self.parent.event.address = addressString
                point.title = places?.first?.name ?? ""
                self.parent.show = true
            }
                
            self.parent.map.setRegion(region, animated: true)
            
            self.parent.map.removeAnnotations(self.parent.map.annotations)
            self.parent.map.addAnnotation(point)
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView(map: .constant(MKMapView()), manager: .constant(CLLocationManager()), alert: .constant(false), source: .constant(CLLocationCoordinate2D()), destination: .constant(CLLocationCoordinate2D()), event: .constant(Event(name: "", description: "", eventIcon: "", host: "", start: Date.now, end: Date.now.addingTimeInterval(3600), address: "", location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))), distance: .constant(""), time: .constant(""), show: .constant(true))
    }
}
