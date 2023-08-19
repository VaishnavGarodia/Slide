//
//  getEventsWithPosts.swift
//  Slide
//
//  Created by Thomas on 7/29/23.
//

import Foundation
import Foundation
import Firebase
import FirebaseFirestore

func getEventGalleryInfos(completion: @escaping ([EventGalleryInfo]?, Error?) -> Void) {
    let eventsCollection = db.collection("Events")
    var eventGalleries: [EventGalleryInfo] = []
    let group = DispatchGroup()

    group.enter()
    eventsCollection.whereField("Associated Highlights", isNotEqualTo: NSNull())
        .getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            for document in snapshot!.documents {
                let eventID = document.documentID

                guard let data = document.data() as? [String: Any],
                      let name = data["Name"] as? String,
                      let icon = data["Icon"] as? String,
                      let eventHighlights = data["Associated Highlights"] as? [String] else {
                    continue
                }
                let eventGallery = EventGalleryInfo(icon: icon, eventName: name, eventID: eventID, postIds: eventHighlights)
                eventGalleries.append(eventGallery)
            }
            group.leave()
    }
    
    group.notify(queue: .main) {
        completion(eventGalleries, nil)
    }
}
