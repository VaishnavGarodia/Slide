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
    @State var eventView = false
    @State var events: [Event] = []
    @State var selectedEvent: Event = .init()
    @State private var isPresentingCreateEventPage = false

    var body: some View {
        ZStack {
            ZStack {
                MapView(map: self.$map, manager: self.$manager, alert: self.$alert, destination: self.$destination, show: self.$show, events: self.$events, eventView: $eventView, selectedEvent: self.$selectedEvent)
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

            EventDrawer(events: $events, selectedEvent: $selectedEvent, map: $map, eventView: $eventView)
        }
        .onAppear {
            fetchEvents()
        }
        .fullScreenCover(isPresented: $isPresentingCreateEventPage) {
            CreateEventPage()
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
                        bannerURL: data["Event Image"] as? String ?? "",
                        hype: data["Hype"] as? String ?? "low"
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
