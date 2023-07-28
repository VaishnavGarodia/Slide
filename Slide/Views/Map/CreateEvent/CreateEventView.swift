//
//  MapView.swift
//  Slide
//
//  Created by Vaishnav Garodia on 7/26/23.
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

struct CreateEventView : UIViewRepresentable {
    
    
    func makeCoordinator() -> Coordinator {
        return CreateEventView.Coordinator(parent1: self)
    }
    
    @Binding var map : MKMapView
    @Binding var manager : CLLocationManager
    @Binding var alert : Bool
    @Binding var source : CLLocationCoordinate2D!
    @Binding var destination : CLLocationCoordinate2D!
    @Binding var name : String
    @Binding var distance : String
    @Binding var time : String
    @Binding var show : Bool
    
    func makeUIView(context: Context) ->  MKMapView {
        
        map.delegate = context.coordinator
        manager.delegate = context.coordinator
        map.showsUserLocation = true
        if let location = self.manager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            self.map.setRegion(region, animated: true)
        }
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.tap(ges:)))
        map.addGestureRecognizer(gesture)
        return map
    }
    
    func updateUIView(_ uiView:  MKMapView, context: Context) {
    }
    
    class Coordinator : NSObject,MKMapViewDelegate,CLLocationManagerDelegate{
        
        var parent : CreateEventView
        
        init(parent1 : CreateEventView) {
            
            parent = parent1
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            
            if status == .denied{
                
                self.parent.alert.toggle()
            }
            else{
                
                self.parent.manager.startUpdatingLocation()
                if let location = self.parent.manager.location?.coordinate {
                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.parent.map.setRegion(region, animated: true)
                    
                }
            }
        }
        
        @objc func tap(ges: UITapGestureRecognizer){
            
            let location = ges.location(in: self.parent.map)
            let mplocation = self.parent.map.convert(location, toCoordinateFrom: self.parent.map)
            
            let point = MKPointAnnotation()
            point.subtitle = "Event"
            point.coordinate = mplocation
            
            self.parent.destination = mplocation
            
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation(CLLocation(latitude: mplocation.latitude, longitude: mplocation.longitude)) { (places, err) in
                
                if err != nil{
                    
                    print((err?.localizedDescription)!)
                    return
                }
                
                self.parent.name = places?.first?.name ?? ""
                point.title = places?.first?.name ?? ""
                
                self.parent.show = true
            }
                
            self.parent.map.setRegion(MKCoordinateRegion(center: mplocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
            
            self.parent.map.removeAnnotations(self.parent.map.annotations)
            self.parent.map.addAnnotation(point)
        }
    }
}
