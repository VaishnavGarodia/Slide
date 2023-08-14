import CoreLocation
import MapKit
import SwiftUI
import FirebaseFirestore

struct MapPage: View {
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var source: CLLocationCoordinate2D!
    @State var destination: CLLocationCoordinate2D!
    @State var event = Event(name: "", description: "", eventIcon: "", host: "", hostName: "", start: Date.now, end: Date.now.addingTimeInterval(3600), address: "", location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), bannerURL: "")
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var book = false
    @State var doc = ""
    @State var data: Data = .init(count: 0)
    @State var events: [EventData] = []
    @State var searchText = ""
    @State var selectedEvent: EventData = EventData(name: "", description: "", host: "", hostName: "", address: "", start: "", end: "", hostUID: "", icon: "", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), bannerURL: "")

    // Gesture Properties...
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    let createEventSearch: Bool = false
    
    @State private var isPresentingCreateEventPage = false

    var body: some View {
        ZStack {
            ZStack {
                MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, distance: self.$distance, time: self.$time, show: self.$show, events: self.$events, selectedEvent: self.$selectedEvent)
                    .ignoresSafeArea()

                ZStack {
                    VStack {
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

//                                Spacer()
//                                NavigationLink(destination: CreateEventPage()) {
//                                    Image(systemName: "plus")
//                                }
//                                .padding(-5)
//                                .filledBubble()
//                                .frame(width: 60)
//                                .padding(.trailing)
//                                .padding(.top, -15)
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
            // For Getting Height For Drag Gesture
            GeometryReader { proxy -> AnyView in
                print("Recieved it back here", selectedEvent)
                let height = proxy.frame(in: .global).height
                return AnyView(
                    ZStack {
                        BlurView(style: .systemThinMaterial)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 15))

                        VStack {

                            Capsule()
                                .fill(.white)
                                .frame(width: 60, height: 4)
                            if !selectedEvent.name.isEmpty {
                                EventDetailsView(
                                    bannerURL: selectedEvent.bannerURL,
                                    icon: selectedEvent.icon,
                                    name: selectedEvent.name,
                                    description: selectedEvent.eventDescription,
                                    host: selectedEvent.host,
                                    hostName: selectedEvent.hostName,
                                    start: selectedEvent.start,
                                    end: selectedEvent.start
                                )
                            } else {
                                ScrollView {
                                    ForEach($events, id: \.name) { event in
                                        ListedEvent(event: event)
                                    }
                                }
                                .padding(.top)
                            }

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
        .fullScreenCover(isPresented: $isPresentingCreateEventPage) {
            ZStack(alignment: .topTrailing) {
                CreateEventPage()
                
                Button(action: {
                    isPresentingCreateEventPage = false
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
    }

    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }

    func fetchEvents() {
        let db = Firestore.firestore()
        db.collection("Events")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                var newEvents: [EventData] = []
                for document in documents {
                    print(document.data())
                    let data = document.data()
                    let coordinate = data["Coordinate"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                    let event = EventData(
                        name: data["Name"] as? String ?? "",
                        description: data["Description"] as? String ?? "",
                        host: data["Host"] as? String ?? "",
                        hostName: data["HostName"] as? String ?? "",
                        address: data["Address"] as? String ?? "",
                        start: data["Start"] as? String ?? "",
                        end: data["End"] as? String ?? "",
                        hostUID: data["HostUID"] as? String ?? "",
                        icon: data["Icon"] as? String ?? "",
                        coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                        bannerURL: data["Event Image"] as? String ?? "")
                    newEvents.append(event)
                }
                self.events = newEvents
                map.addAnnotations(events)
            }
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
