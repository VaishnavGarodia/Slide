// MapPage.swift
// Slide
// Created by Vaishnav Garodia

import CoreLocation
import FirebaseFirestore
import MapKit
import SwiftUI

struct MapPage: View {
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var destination: CLLocationCoordinate2D!
    @State var show = false
    @State private var eventView = false
    @State var events: [Event] = []
    @State var selectedEvent: Event = .init()
    @State private var isPresentingCreateEventPage = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapView(map: $map, manager: $manager, alert: $alert, destination: $destination, show: $show, events: $events, eventView: $eventView, selectedEvent: $selectedEvent)
                .ignoresSafeArea()
            
            ZStack(alignment: .topLeading) {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresentingCreateEventPage = true
                    }) {
                        Image(systemName: "plus")
                            .padding(-5)
                            .filledBubble()
                            .frame(width: 60)
                            .padding(.trailing)
                            .padding(.top, -15)
                    }
                }
                
                SearchView(map: $map, location: $destination, event: $selectedEvent, detail: $show, eventView: $eventView, searchForEvents: true, frame: 300)
                    .padding(.top, -15)
            }
            .alert(isPresented: self.$alert) { () -> Alert in
                Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
            }
            
            Button {
                withAnimation {
                    zoomToUserLocation()
                }
            } label: {
                Image(systemName: "location")
                    .filledBubble()
                    .frame(width: 50, height: 50)
                    .padding()
                    .padding(.bottom)
                    .padding(.bottom)
            }
            
            EventDrawer(events: $events, selectedEvent: $selectedEvent, map: $map, eventView: $eventView)
        }
        .onAppear {
            checkHype()
        }
        .fullScreenCover(isPresented: $isPresentingCreateEventPage) {
            CreateEventPage()
        }
    }
    
    func checkHype() {
        let group = DispatchGroup()
        let docRef = db.collection("HypestEventScore").document("hypestEventScore")
        if hypestEventScore == 0 {
            group.enter()
            docRef.getDocument { scoreDocument, _ in
                if let scoreDocument = scoreDocument, scoreDocument.exists {
                    if let scoreData = scoreDocument.data() {
                        print("Document data: \(scoreData)")
                        if let score = scoreData["score"] as? Int {
                            print("Hypest event score: \(score)")
                            hypestEventScore = score
                        } else {
                            print("Score not found in document.")
                        }
                    }
                    // Update the document with the new score
                }
                group.leave()
            }
            group.notify(queue: .main) {
                fetchEvents()
            }
        }
    }
    
    func fetchEvents() {
        let currentDate = Date()
//        let fiveHoursLater = Calendar.current.date(byAdding: .hour, value: 5, to: currentDate)!
        db.collection("Events").whereField("End", isGreaterThan: currentDate)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                var newEvents: [Event] = []
                for document in documents {
                    let data = document.data()
                    let coordinate = data["Coordinate"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                    let event = Event(
                        name: data["Name"] as? String ?? "",
                        description: data["Description"] as? String ?? "",
                        address: data["Address"] as? String ?? "",
                        start: (data["Start"] as? Timestamp)?.dateValue() ?? Date(),
                        end: (data["End"] as? Timestamp)?.dateValue() ?? Date(),
                        hostUID: data["HostUID"] as? String ?? "",
                        icon: data["Icon"] as? String ?? "",
                        coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                        bannerURL: data["BannerURL"] as? String ?? "",
                        hype: data["Hype"] as? String ?? "",
                        id: document.documentID,
                        slides: data["SLIDES"] as? [String] ?? [],
                        highlights: data["Associated Highlights"] as? [String] ?? []
                    )
                    newEvents.append(event)
                }
                events = newEvents
                map.addAnnotations(events)
            }
    }

    func zoomToUserLocation() {
        if let userLocation = map.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            map.setRegion(region, animated: true)
        }
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
