import FirebaseFirestore
import MapKit
import SwiftUI
import ObjectiveC

class Event: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var address, bannerURL, eventDescription, host, hostName, hostUID, icon, name: String
    var start, end: Date
    var coordinate: CLLocationCoordinate2D

    init(name: String, description: String, host: String, hostName: String, address: String, start: Date, end: Date, hostUID: String, icon: String, coordinate: CLLocationCoordinate2D, bannerURL: String) {
        self.name = name
        self.title = name
        self.eventDescription = description
        self.subtitle = description
        self.host = host
        self.hostName = hostName
        self.address = address
        self.start = start
        self.end = end
        self.hostUID = hostUID
        self.icon = icon
        self.coordinate = coordinate
        self.bannerURL = bannerURL
    }

    override init() {
        self.name = ""
        self.title = ""
        self.eventDescription = ""
        self.subtitle = ""
        self.host = ""
        self.hostName = ""
        self.address = ""
        self.start = Date()
        self.end = Date()
        self.hostUID = ""
        self.icon = ""
        self.coordinate = CLLocationCoordinate2D()
        self.bannerURL = "https://static01.nyt.com/images/2023/02/13/multimedia/08BEFORE-MIDNIGHT-fzql/08BEFORE-MIDNIGHT-fzql-articleLarge.jpg?quality=75&auto=webp&disable=upscale"
    }
}
