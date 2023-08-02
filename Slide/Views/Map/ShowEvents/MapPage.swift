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
    let createEventSearch: Bool = false

    var body: some View {
        ZStack {
            MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, distance: self.$distance, time: self.$time, show: self.$show)
                .ignoresSafeArea()

            ZStack {
                VStack {
                    ZStack(alignment: .topLeading) {
                        HStack {
                            Spacer()
                            NavigationLink(destination: CreateEventPage()) {
                                Image(systemName: "plus")
                            }
                            .padding(-5)
                            .filledBubble()
                            .frame(width: 60)
                            .padding(.trailing)
                            .padding(.top, -15)
                        }

                        SearchView(map: self.$map, location: self.$destination, event: self.$event, detail: self.$show, createEventSearch: self.createEventSearch, frame: 300)
                            .padding(.top, -15)
                    }
                    Spacer()
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
