//
//  getEventGalleries.swift
//  Slide
//
//  Created by Thomas on 7/29/23.
//

import CoreLocation
import Firebase
import Foundation

func getEventGalleries(completion: @escaping ([Event]?, Error?) -> Void) {
    var user = Auth.auth().currentUser

    var friendList: [String] = []
    let group = DispatchGroup()
    guard let currentUserID = user?.uid else {
        return
    }
    let userDocumentRef = db.collection("Users").document(currentUserID)
    group.enter()
    userDocumentRef.getDocument(completion: { d2, _ in
        if let d2 = d2, d2.exists {
            if let tempFriendsArray = d2.data()?["Friends"] as? [String] {
                friendList = tempFriendsArray
            }
        }
        group.leave()
    })
    print(friendList)

                                
    let eventsCollection = db.collection("Events")
    var eventGalleries: [Event] = []

    group.enter()
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
                    highlights: data["Associated Highlights"] as? [String] ?? []
                )
                print(event.hostUID)
                if friendList.contains(event.hostUID) {
                    eventGalleries.append(event)
                    print("Added")
                }
                else {
                    var add = false
                    for highlightID in event.highlights {
                        let highlightDocRef = db.collection("Posts").document(highlightID)
                        group.enter()
                        highlightDocRef.getDocument(completion: {d3, e3 in
                            if let d3 = d3, d3.exists {
                                if let postUserID = d3.data()?["User"] as? String {
                                    print(postUserID)
                                    if friendList.contains(postUserID) {
                                        add = true
                                        return
                                    }
                                }
                            }
                            group.leave()
                        })
                    }
                    if add {
                        eventGalleries.append(event)
                        print("Added")
                    }
                    else if event.slides.contains(currentUserID) {
                        eventGalleries.append(event)
                        print("Added")
                    }
                }
                
            }
            group.leave()
        }

    group.notify(queue: .main) {
        completion(eventGalleries, nil)
    }
}
