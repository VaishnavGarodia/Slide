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

struct Event {
    var name, description, eventIcon: String
    var start, end: Date
    var address: String
}

struct CreateEventPage: View {
    @State private var event = Event(name: "", description: "", eventIcon: "", start: Date.now, end: Date.now.addingTimeInterval(3600), address: "")
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
    let createEventSearch: Bool = true
    
    var body: some View {
        ZStack {
            CreateEventView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, name: self.$name, distance: self.$distance, time: self.$time, show: self.$show)
                .ignoresSafeArea()
                .onAppear {
                    self.manager.requestAlwaysAuthorization()
                }
            VStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(self.destination != nil ? "Destination" : "New Page")
                                .font(.title)
                            
                            if self.destination != nil {
                                Text(self.name)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            self.search.toggle()
                            
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Circle().foregroundColor(.accentColor))
                    }
                    .padding()
                    .background()
                    
                    if self.destination != nil && self.show {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 20) {
                                TextField("Name your event!", text: self.$event.name)
                                    .bubbleStyle(color: .primary)
                                    .padding(.top)
                                TextField("Put an event description", text: self.$event.description)
                                    .frame(height: 100, alignment: .topLeading)
                                    .bubbleStyle(color: .primary)
                                TextField("Address", text: self.$event.address)
                                    .frame(height: 100, alignment: .topLeading)
                                    .bubbleStyle(color: .primary)
                                DatePicker("When does it start?", selection: self.$event.start, in: Date()...)
                                    .onAppear {
                                        UIDatePicker.appearance().minuteInterval = 15
                                    }

                                    .datePickerStyle(.compact)
                                DatePicker("When does it end?", selection: self.$event.end, in: self.event.start...)
                                    .onAppear {
                                        UIDatePicker.appearance().minuteInterval = 15
                                    }
                                
                                Picker("Event Icon", selection: self.$event.eventIcon) {
                                    Image(systemName: "figure.basketball").tag("figure.basketball")
                                    Image(systemName: "party.popper").tag("party.popper")
                                    Image(systemName: "theatermasks").tag("theatersmasks")
                                }
                                .pickerStyle(.segmented)
                                
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
                        .padding()
                        .background(Color.white)
                    }
                }
                
                Spacer()
                
                if self.loading {
                    Loader()
                }
                
                if self.book {
                    Booked(data: self.$data, doc: self.$doc, loading: self.$loading, book: self.$book)
                }
                
                if self.search {
                    SearchView(show: self.$search, map: self.$map, source: self.$source, location: self.$destination, name: self.$name, distance: self.$distance, time: self.$time, detail: self.$show, createEventSearch: self.createEventSearch)
                }
            }
        }
        .alert(isPresented: self.$alert) { () -> Alert in
            
            Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
        }
    }
    
    func createEvent() {
        let db = Firestore.firestore()
        let doc = db.collection("Events").document()
        self.doc = doc.documentID
        
        let location = GeoPoint(latitude: self.destination.latitude, longitude: self.destination.longitude)
        print("Creating event for location: ", location)
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

struct CreateEventPage_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventPage()
    }
}
