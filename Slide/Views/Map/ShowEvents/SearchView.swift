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
    @Binding var event : Event
    @Binding var distance : String
    @Binding var time : String
    @State var txt = ""
    @Binding var detail : Bool
    @State var createEventSearch : Bool = false
    
    var body: some View {
        
        GeometryReader{_ in
            
            VStack(spacing: 0){
                
                SearchBar(map: self.$map, source: self.$source, destination: self.$location , result: self.$result, distance: self.$distance, time: self.$time,txt: self.$txt)
                
                if self.txt != ""{
                    List(self.result){i in
                        VStack(alignment: .leading){
                            
                            Text(i.name)
                            
                            Text(i.address)
                                .font(.caption)
                        }
                        .onTapGesture {
                            searchLocation(query : i.result)
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
    
    func searchLocation(query: MKLocalSearchCompletion) {
        let req = MKLocalSearch.Request(completion: query)
        req.region = self.map.region
        var lat : Double = 0.0
        var lon : Double = 0.0
        let search = MKLocalSearch(request: req)
                search.start { (response, error) in
                    guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                        return
                    }

                    guard let name = response?.mapItems[0].name else {
                        return
                    }

                    lat = coordinate.latitude
                    lon = coordinate.longitude

                    print(lat)
                    print(lon)
                    self.location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    print(name)
                    self.UpdateMap(placeName : name)
                    self.show.toggle()
                }
    }
    
    func UpdateMap(placeName : String?){
        if (self.createEventSearch) {
            var addressString : String = ""
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            let point = MKPointAnnotation()
            point.subtitle = "Event location"
            point.coordinate = self.location
            
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation(CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)) { (places, err) in
                
                if err != nil{
                    
                    print((err?.localizedDescription)!)
                    return
                }
                let pm = places! as [CLPlacemark]
                if pm.count > 0 {
                                    let pm = places![0]
                                    print("name" , placeName)
                                    print(pm.country)
                                    print(pm.locality)
                                    print(pm.subLocality)
                                    print(pm.thoroughfare)
                                    print(pm.subThoroughfare)
                                    print(pm.postalCode)
                                    print(pm.subThoroughfare)
                                    if placeName != nil {
                                        addressString = addressString + (placeName ?? "") + ", "
                                    }
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
                
                self.event.address = addressString
                point.title = places?.first?.name ?? ""
                self.detail = true
            }
            self.map.removeAnnotations(self.map.annotations)
            self.map.addAnnotation(point)
            self.map.setRegion(region, animated: true)
            
        } else {
            
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            print("center at", self.location)
            let region = MKCoordinateRegion(center: self.location, span: span)
            self.map.setRegion(region, animated: true)
            
        }
    }
    
    
    struct SearchBar : UIViewRepresentable {
        
        @Binding var map : MKMapView
        @Binding var source : CLLocationCoordinate2D!
        @Binding var destination : CLLocationCoordinate2D!
        @Binding var result : [SearchData]
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
        
        class Coordinator : NSObject,UISearchBarDelegate,MKLocalSearchCompleterDelegate{
            
            var parent : SearchBar
            private lazy var searchCompleter: MKLocalSearchCompleter = {
                    let completer = MKLocalSearchCompleter()
                    completer.delegate = self
                    return completer
                }()
            var searchResults = [MKLocalSearchCompletion]()
            
            init(parent1 : SearchBar) {
                parent = parent1
            }
            
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                print("creating search for" + searchText)
                self.parent.txt = searchText
                print("self.parent.txt", self.parent.txt)
                searchCompleter.region = self.parent.map.region
                searchCompleter.queryFragment = searchText
            }
            
            // This method declares gets called whenever the searchCompleter has new search results
            // If you wanted to do any filter of the locations that are displayed on the the table view
            // this would be the place to do it.
            func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
                // Setting our searcResults variable to the results that the searchCompleter returned
                searchResults = completer.results
                DispatchQueue.main.async {
                    self.parent.result.removeAll()
                    for i in 0..<self.searchResults.count{
                        
                        let temp = SearchData(id: i, name: self.searchResults[i].title, address: self.searchResults[i].subtitle, result: self.searchResults[i])
                        print(temp)
                        
                        self.parent.result.append(temp)
                    }
                }
            }

            // This method is called when there was an error with the searchCompleter
            func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
                print("Error occured")
            }
                
                }
        
            }
    
        }


struct SearchData : Identifiable {
    
    var id : Int
    var name : String
    var address : String
    var result: MKLocalSearchCompletion
}
