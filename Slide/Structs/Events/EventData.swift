import MapKit
import ObjectiveC

class EventData: NSObject, MKAnnotation {
  var name: String
  var title: String?
  var eventDescription: String
  var host, address, start, end, hostUID, icon: String
  var coordinate: CLLocationCoordinate2D
  init(name: String, description: String, host: String, address: String, start: String, end: String, hostUID: String, icon: String, coordinate: CLLocationCoordinate2D) {
    self.name = name
    self.title = name
    self.eventDescription = description
    self.host = host
    self.address = address
    self.start = start
    self.end = end
    self.hostUID = hostUID
    self.icon = icon
    self.coordinate = coordinate
  }
}
