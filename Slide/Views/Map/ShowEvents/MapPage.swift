import CoreLocation
import FirebaseFirestore
import MapKit
import SwiftUI

struct MapPage: View {
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var destination: CLLocationCoordinate2D!
    @State var event = Event()
    @State var show = false
    @State var events: [Event] = []
    @State var selectedEvent: Event = .init()

    // Gesture Properties...
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    @State private var isPresentingCreateEventPage = false

    var body: some View {
        ZStack {
            ZStack {
                MapView(map: self.$map, manager: self.$manager, alert: self.$alert, destination: self.$destination, show: self.$show, events: self.$events, selectedEvent: self.$selectedEvent)
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
                            }

                            SearchView(map: self.$map, location: self.$destination, event: self.$event, detail: self.$show, frame: 300)
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
                                    event: selectedEvent
                                ).onAppear {
                                    let coordinateRegion = MKCoordinateRegion(
                                        center: selectedEvent.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                    )
                                    map.setRegion(coordinateRegion, animated: true)
                                }
                            } else {
                                ScrollView {
                                    ForEach($events, id: \.name) { event in
                                        ListedEvent(event: event, selectedEvent: $selectedEvent)
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
        let currentDate = Date()
        let fiveHoursLater = Calendar.current.date(byAdding: .hour, value: 5, to: currentDate)!
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
                        host: data["Host"] as? String ?? "",
                        hostName: data["HostName"] as? String ?? "",
                        address: data["Address"] as? String ?? "",
                        start: (data["Start"] as? Timestamp)?.dateValue() ?? Date(),
                        end: (data["End"] as? Timestamp)?.dateValue() ?? Date(),
                        hostUID: data["HostUID"] as? String ?? "",
                        icon: data["Icon"] as? String ?? "",
                        coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                        bannerURL: data["Event Image"] as? String ?? ""
                    )
                    newEvents.append(event)
                }
                print(newEvents)
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
