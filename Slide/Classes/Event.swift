import FirebaseFirestore
import MapKit
import SwiftUI
import ObjectiveC

class Event: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var address, bannerURL, eventDescription, host, hostUID, icon, id, name: String
    var start, end: Date
    var coordinate: CLLocationCoordinate2D
    var hype: String
    
    init(name: String, description: String, host: String, address: String, start: Date, end: Date, hostUID: String, icon: String, coordinate: CLLocationCoordinate2D, bannerURL: String, hype: String, id: String) {
        self.name = name
        self.title = name
        self.eventDescription = description
        self.subtitle = description
        self.host = host
        self.address = address
        self.start = start
        self.end = end
        self.hostUID = hostUID
        self.icon = icon
        self.coordinate = coordinate
        self.bannerURL = bannerURL
        self.hype = hype //Types are low, medium, high for now.
        self.id = id
    }

    override init() {
        self.name = ""
        self.title = ""
        self.eventDescription = ""
        self.subtitle = ""
        self.host = ""
        self.address = ""
        self.start = Date()
        self.end = Date()
        self.hostUID = ""
        self.icon = ""
        self.coordinate = CLLocationCoordinate2D()
        self.bannerURL = ""
        self.hype = "low"
        self.id = ""
    }
}

