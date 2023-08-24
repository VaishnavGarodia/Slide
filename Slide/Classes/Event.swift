import FirebaseFirestore
import MapKit
import SwiftUI
import ObjectiveC

class Event: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var address, bannerURL, eventDescription, host, hostUID, hype, icon, id, name: String
    var start, end: Date
    var coordinate: CLLocationCoordinate2D
    var slides, highlights: [String]
    
    init(name: String, description: String, host: String, address: String, start: Date, end: Date, hostUID: String, icon: String, coordinate: CLLocationCoordinate2D, bannerURL: String, hype: String, id: String, slides: [String], highlights: [String], hypestEventScore: Int) {

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
        self.slides = slides
        self.highlights = highlights
        let hypeAmount: Int = slides.count + 2*highlights.count
        if (hypeAmount>hypestEventScore){
            // Reference to Firestore database
            let db = Firestore.firestore()

            // Reference to the document
            let docRef = db.collection("HypestEventScore").document("hypestEventScore")

            // Update the document with the new score
            docRef.updateData(["score": hypeAmount]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated with new score.")
                }
            }
        }
        if (self.hype==""){
            let hypeScore: Float = Float((hypeAmount/hypestEventScore) * 100)
            if (hypeScore>0 && hypeScore<30){
                self.hype = "low"
            } else if (hypeScore>30 && hypeScore<70) {
                self.hype = "medium"
            } else if (hypeScore>70){
                self.hype = "high"
            }
        }
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
        self.slides = []
        self.highlights = []
    }
}

