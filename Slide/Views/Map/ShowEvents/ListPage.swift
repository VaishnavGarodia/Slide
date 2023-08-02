//  ListPage.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import SwiftUI
import CoreLocation
import MapKit
import FirebaseFirestore

struct ListPage: View {
    @State private var events: [EventData] = []
    @State var searchText = ""
    
    // Gesture Properties...
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            MapPage()
//                .blur(radius: getBlurRadius())

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

                            // Content
//                            HStack {
//                                Image(systemName: "magnifyingglass")
//                                TextField("Search", text: $searchText)
//                            }
//                            .checkMarkTextField()
//                            .bubbleStyle(color: .primary)
//                            .padding(.top)
                            
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
                            
                        // Storing Last Offset...
                        // So that the gesture can contine from the last position....
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

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> some UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ListPage_Previews: PreviewProvider {
    static var previews: some View {
        ListPage()
    }
}
