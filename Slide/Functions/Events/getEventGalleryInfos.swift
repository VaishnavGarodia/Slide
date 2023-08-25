//
//  getEventGalleries.swift
//  Slide
//
//  Created by Thomas on 7/29/23.
//

import CoreLocation
import Firebase
import FirebaseFirestore
import Foundation

func getEventGalleries(completion: @escaping ([Event]?, Error?) -> Void) {
    let eventsCollection = db.collection("Events")
    var eventGalleries: [Event] = []
    let group = DispatchGroup()
    var hypestEventScore = 0

    group.enter()
    db.collection("HypestEventScore").document("hypestEventScore").getDocument { scoreDocument, _ in
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
        }
        eventsCollection.whereField("Associated Highlights", isNotEqualTo: [String]())
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }

                for document in snapshot!.documents {
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
                        highlights: data["Associated Highlights"] as? [String] ?? [],
                        hypestEventScore: hypestEventScore
                    )
                    eventGalleries.append(event)
                }
                group.leave()
            }
    }

    group.notify(queue: .main) {
        completion(eventGalleries, nil)
    }
}
