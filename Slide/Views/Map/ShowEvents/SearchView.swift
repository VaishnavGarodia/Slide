//
//  SearchView.swift
//  Slide
//
//  Created by Vaishnav Garodia on 7/26/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct SearchView: View {
    
    @State var result : [SearchData] = []
    @Binding var show : Bool
    @Binding var map : MKMapView
    @Binding var source : CLLocationCoordinate2D!
    @Binding var location : CLLocationCoordinate2D!
    @Binding var name : String
    @Binding var distance : String
    @Binding var time : String
    @State var txt = ""
    @Binding var detail : Bool
    @State var createEventSearch : Bool = false
    
    var body: some View {
        
        GeometryReader{_ in
            
            VStack(spacing: 0){
                
                SearchBar(map: self.$map, source: self.$source, destination: self.$location , result: self.$result, name: self.$name, distance: self.$distance, time: self.$time,txt: self.$txt)
                
                if self.txt != ""{
                    
                    List(self.result){i in
                        
                        VStack(alignment: .leading){
                            
                            Text(i.name)
                            
                            Text(i.address)
                                .font(.caption)
                        }
                        .onTapGesture {
                            
                            self.location = i.coordinate
                            self.UpdateMap()
                            self.show.toggle()
                        }
                    }
                }
            }
            
        }
        .padding()
        .background(Color.black.opacity(0.4).ignoresSafeArea()
            .onTapGesture {
                self.show.toggle()
            })
    }
    
    func UpdateMap(){
        if (self.createEventSearch) {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            let point = MKPointAnnotation()
            point.subtitle = "Event location"
            point.coordinate = location
            

            
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation(CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)) { (places, err) in
                
                if err != nil{
                    
                    print((err?.localizedDescription)!)
                    return
                }
                
                self.name = places?.first?.name ?? ""
                point.title = places?.first?.name ?? ""
                
                self.detail = true
            }
            self.map.removeAnnotations(self.map.annotations)
            self.map.addAnnotation(point)
            self.map.setRegion(region, animated: true)
            
        } else {
            
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            self.map.setRegion(region, animated: true)
            
        }
    }
    
    
    struct SearchBar : UIViewRepresentable {
        
        @Binding var map : MKMapView
        @Binding var source : CLLocationCoordinate2D!
        @Binding var destination : CLLocationCoordinate2D!
        @Binding var result : [SearchData]
        @Binding var name : String
        @Binding var distance : String
        @Binding var time : String
        @Binding var txt : String
        
        func makeCoordinator() -> Coordinator {
            
            return SearchBar.Coordinator(parent1: self)
        }
        
        func makeUIView(context: Context) -> UISearchBar {
            
            let view = UISearchBar()
            view.autocorrectionType = .no
            view.autocapitalizationType = .none
            view.delegate = context.coordinator
            
            return view
        }
        
        func updateUIView(_ uiView:  UISearchBar, context: Context) {
            
            
        }
        
        class Coordinator : NSObject,UISearchBarDelegate{
            
            var parent : SearchBar
            
            init(parent1 : SearchBar) {
                
                parent = parent1
            }
            
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                
                self.parent.txt = searchText
                
                let req = MKLocalSearch.Request()
                req.naturalLanguageQuery = searchText
                req.region = self.parent.map.region
                
                let search = MKLocalSearch(request: req)
                
                DispatchQueue.main.async {
                    
                    self.parent.result.removeAll()
                }
                
                search.start { (res, err) in
                    
                    if err != nil{
                        
                        print((err?.localizedDescription)!)
                        return
                    }
                    
                    for i in 0..<res!.mapItems.count{
                        
                        let temp = SearchData(id: i, name: res!.mapItems[i].name!, address: res!.mapItems[i].placemark.title!, coordinate: res!.mapItems[i].placemark.coordinate)
                        
                        self.parent.result.append(temp)
                    }
                }
            }
        }
    }
}


struct SearchData : Identifiable {
    
    var id : Int
    var name : String
    var address : String
    var coordinate : CLLocationCoordinate2D
}
