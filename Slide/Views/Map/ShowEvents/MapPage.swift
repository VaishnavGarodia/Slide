//
//  MapPage.swift
//  Slide
//
//  Created by Vaishnav Garodia
//

import CoreLocation
import FirebaseFirestore
import MapKit
import SwiftUI

struct MapPage: View {
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var source: CLLocationCoordinate2D!
    @State var destination: CLLocationCoordinate2D!
    @State var name = ""
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var book = false
    @State var doc = ""
    @State var data: Data = .init(count: 0)
    @State var search = false
    
    var body: some View {
        ZStack {
            MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, name: self.$name, distance: self.$distance, time: self.$time, show: self.$show)
                .ignoresSafeArea()
                .onAppear {
                    self.manager.requestAlwaysAuthorization()
                }
            ZStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(self.destination != nil ? "Destination" : "Pick a Location")
                                .font(.title)
                            
                            if self.destination != nil {
                                Text(self.name)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Circle().foregroundColor(.accentColor))
                        
                        Button(action: {
                            self.search.toggle()
                            
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Circle().foregroundColor(.accentColor))
                    }
                    .padding()
                    .background()
                    
                    Spacer()
                    
                    if self.loading {
                        Loader()
                    }
                    
                    if self.book {
                        Booked(data: self.$data, doc: self.$doc, loading: self.$loading, book: self.$book)
                    }
                    
                    if self.search {
                        SearchView(show: self.$search, map: self.$map, source: self.$source, destination: self.$destination, name: self.$name, distance: self.$distance, time: self.$time, detail: self.$show)
                    }
                }
                
                if self.destination != nil && self.show {
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Destination")
                                        .fontWeight(.bold)
                                    Text(self.name)
                                }
                                
                                Spacer()
                            }
                            
                            Button(action: {
                                self.loading.toggle()
                                
                                self.createEvent()
                                
                            }) {
                                Text("Create Event")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .frame(width: UIScreen.main.bounds.width / 2)
                            }
                            .background(Color.red)
                            .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            self.map.removeOverlays(self.map.overlays)
                            self.map.removeAnnotations(self.map.annotations)
                            self.destination = nil
                            
                            self.show.toggle()
                            
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                    .background(Color.white)
                }
            }
            
            
        }
        .alert(isPresented: self.$alert) { () -> Alert in
            
            Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
        }
    }
    
    func createEvent() {
        let doc = db.collection("Events").document()
        self.doc = doc.documentID
        
        let location = GeoPoint(latitude: self.destination.latitude, longitude: self.destination.longitude)
        
        doc.setData(["name": "Kavsoft", "location": location]) { err in
            
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            self.loading.toggle()
            self.book.toggle()
        }
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
