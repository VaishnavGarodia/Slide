//
// MapPage.swift
// Slide
//
// Created by Vaishnav Garodia
//
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import MapKit
import SwiftUI

struct Event {
    var name, description, eventIcon, host: String
    var start, end: Date
    var address: String
    var location: CLLocationCoordinate2D
}

struct CreateEventPage: View {
    
    @State private var map = MKMapView()
    @State var event = Event(name: "", description: "", eventIcon: "", host: "", start: Date.now, end: Date.now.addingTimeInterval(3600), address: "", location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    @State var destination: CLLocationCoordinate2D!
    @State var show = false
    @State private var createEventSearch: Bool = true
    @State var alert = false
    var body: some View {
        ZStack {
            CreateEventView(map: $map, event: $event, alert: $alert, show: $show)
                .ignoresSafeArea()

            if self.destination != nil && self.show {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundColor(.black.opacity(0.5))
            }
            VStack {
                VStack(alignment: .center) {
                    HStack {
                        ZStack(alignment: .topLeading) {
                            SearchView(map: $map, location: self.$destination, event: self.event, detail: self.$show, createEventSearch: self.createEventSearch, frame: 280)
                                .padding(.top, -15)
                        }
                    }
                    if self.destination != nil && self.show {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 10) {
                                TextField("Event Name", text: self.$event.name)
                                    .bubbleStyle(color: .primary)
                                    .padding(.top)
                                TextField("Event Description", text: self.$event.description, axis: .vertical)
                                    .frame(height: 50, alignment: .topLeading)
                                    .bubbleStyle(color: .primary)
                                TextField("Address", text: self.$event.address, axis: .vertical)
                                    .frame(height: 50, alignment: .topLeading)
                                    .bubbleStyle(color: .primary)
                                DatePicker("Event Start", selection: self.$event.start, in: Date()...)
                                    .onAppear {
                                        UIDatePicker.appearance().minuteInterval = 15
                                    }
                                    .datePickerStyle(.compact)
                                DatePicker("Event End", selection: self.$event.end, in: self.event.start...)
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
//                                    self.loading.toggle()
                                    self.event.location = CLLocationCoordinate2D(latitude: self.destination.latitude, longitude: self.destination.longitude)
                                    self.createEvent()
                                }) {
                                    Text("Create Event")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .frame(width: UIScreen.main.bounds.width / 2)
                                }
                                .filledBubble()
                                .padding()
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
                    }
                }
                Spacer()
//                if self.loading {
//                    Loader()
//                }
//                if self.book {
//                    Booked(data: self.$data, doc: self.$doc, loading: self.$loading, book: self.$book)
//                }
            }
        }
//        .alert(isPresented: self.$alert) { () -> Alert in
//            Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
//        }
    }

    func createEvent() {
        let doc = db.collection("Events").document()
//        self.doc = doc.documentID
        print("Creating event for location: ", self.event.location)
        doc.setData(["HostUID": Auth.auth().currentUser!.uid, "Name": self.event.name, "Description": self.event.description, "Icon": self.event.eventIcon, "Host": Auth.auth().currentUser!.displayName!, "Address": self.event.address, "Location": GeoPoint(latitude: self.event.location.latitude, longitude: self.event.location.longitude)]) { err in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
//            self.loading.toggle()
//            self.book.toggle()
        }
    }
}

struct CreateEventPage_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventPage()
    }
}
