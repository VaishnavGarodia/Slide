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
    @State var event = Event(name: "", description: "", eventIcon: "", eventPoster: "", start: Date.now, end: Date.now.addingTimeInterval(3600), address: "", location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var book = false
    @State var doc = ""
    @State var data: Data = .init(count: 0)
    @State var search = false
    let createEventSearch : Bool = false
    var body: some View {
        ZStack {
            MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, distance: self.$distance, time: self.$time, show: self.$show)
                .ignoresSafeArea()
                .onAppear {
                    self.manager.requestAlwaysAuthorization()
                }
            ZStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(self.destination != nil ? "Destination" : "Events Around You")
                                .font(.title)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: CreateEventPage()) {
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
                    
                    if self.search {
                        SearchView(show: self.$search, map: self.$map, source: self.$source, location: self.$destination, event: self.$event, distance: self.$distance, time: self.$time, detail: self.$show, createEventSearch: self.createEventSearch)
                    }
                }
            }
        }
        .alert(isPresented: self.$alert) { () -> Alert in
            
            Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
        }
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
