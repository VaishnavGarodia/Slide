//  ListPage.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import SwiftUI
import CoreLocation
import MapKit
import FirebaseFirestore

struct ListPage: View {
    @State private var creation = false
    @State private var events: [EventData] = []
    @State private var lastOffset: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var searchText = ""
    @GestureState private var gestureOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            if creation {
                CreateEventPage(creation: $creation)
                    .transition(.opacity)
            } else {
                MapPage(creation: $creation)
                    .transition(.opacity)
            }

            // For Getting Height For Drag Gesture
            GeometryReader { proxy -> AnyView in
                let height = proxy.frame(in: .global).height
                return AnyView(
                    ZStack {
                        BlurView(style: .systemThinMaterial)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 15))
                        
                        VStack {

                            Capsule()
                                .fill(.white)
                                .frame(width: 60, height: 4)
                            
                            ScrollView {
                                ForEach($events, id: \.name) { event in
                                    ListedEvent(event: event)
                                }
                            }
                            .padding(.top)
                        
                            Divider()
                                .background(.white)
                            
                            Spacer()
                        } //: VSTACK
                        .padding(16)
                    } //: ZSTACK
                    .offset(y: height - 30)
                    .offset(y: -offset > 0 ? -offset <= (height - 30) ? offset : -(height - 30) : 0)
                    .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                        out = value.translation.height
                        onChange()
                    }).onEnded { _ in
                        let maxHeight = height - 30
                        withAnimation {
                            // offset = 0
                                
                            // Logic Conditions For Moving States....
                            // Up down or mid...
                            if -offset > 30, -offset < maxHeight / 2 {
                                // Mid...
                                offset = -(maxHeight / 3)
                            } else if -offset > maxHeight / 2 {
                                offset = -maxHeight
                            } else {
                                offset = 0
                            }
                        }
                    
                        lastOffset = offset
                            
                    })
                )
            }
        }
        .onAppear {
            fetchEvents()
        }
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
    
    // Blur Radius for BG...
    func getBlurRadius() -> CGFloat {
        let progress = -offset / (UIScreen.main.bounds.height - 100)
        return progress * 30
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
                   let hostUID = document.data()["HostUID"] as? String,
                   let coordinate = document.data()["Coordinate"] as? GeoPoint
                {
                    let event = EventData(name: name, description: description, host: host, address: address, start: start, end: end, hostUID: hostUID, icon: icon, coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
                    newEvents.append(event)
                    print(newEvents)
                }
            }
            self.events = newEvents
        }
    }
}

struct ListPage_Previews: PreviewProvider {
    static var previews: some View {
        ListPage()
    }
}
