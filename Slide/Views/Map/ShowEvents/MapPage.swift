//  MapPage.swift
//  Slide
//  Created by Vaishnav Garodia

import CoreLocation
import MapKit
import SwiftUI

struct MapPage: View {
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var source: CLLocationCoordinate2D!
    @State var destination: CLLocationCoordinate2D!
    @State var event = Event(name: "", description: "", eventIcon: "", host: "", start: Date.now, end: Date.now.addingTimeInterval(3600), address: "", location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var book = false
    @State var doc = ""
    @State var data: Data = .init(count: 0)
    @State private var list = false
    @State private var events: [EventData] = []
    let createEventSearch: Bool = false
    
    var body: some View {
        ZStack {
            MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, distance: self.$distance, time: self.$time, show: self.$show)
                .ignoresSafeArea()
                
            ZStack {
                VStack {
                    ZStack {
                        VStack {
                            
                            HStack {
                                Spacer()
                                NavigationLink(destination: CreateEventPage()) {
                                    Image(systemName: "plus")
                                }
                                .foregroundColor(.primary)
                                .padding(5)
                            .background(Circle().foregroundColor(.accentColor))
                            .padding(.top, 30)
                            }
                            Spacer()
                        }
                        SearchView(map: self.$map, location: self.$destination, event: self.$event, detail: self.$show, createEventSearch: self.createEventSearch)
                        
                    }
                    Spacer()
                    Button {
                        list = true
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                }
            }
        }
        .onAppear {
                fetchEvents()
                print("fuck")
                print(events)
        }
        .sheet(isPresented: $list) {
            ListPage(events: $events)
        }
        .alert(isPresented: self.$alert) { () -> Alert in
            Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
        }
    }
    
    
    func fetchEvents() {
        let eventsRef = db.collection("Events")

        eventsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching highlights: \(error.localizedDescription)")
                return
            }

            var newEvents: [EventData] = []

            for document in snapshot?.documents ?? [] {
                if let description = document.data()["Description"] as? String,
                   let address = document.data()["Address"] as? String,
                   let name = document.data()["Name"] as? String,
                   let host = document.data()["Host"] as? String,
                   let start = document.data()["Start"] as? String,
                   let end = document.data()["End"] as? String,
                   let icon = document.data()["Icon"] as? String,
                   let hostUID = document.data()["HostUID"] as? String
                   {
                    
                    let event = EventData(name: name, description: description, host: host, address: address, start: start, end: end, hostUID: hostUID, icon: icon)
                    newEvents.append(event)
                    print(newEvents)
                }
            }
            self.events = newEvents
            print(events)
        }
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
