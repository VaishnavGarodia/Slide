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
    let user = Auth.auth().currentUser

    var friendList: [String] = []
    guard let currentUserID = user?.uid else {
        return
    }
    
    let initialGroup = DispatchGroup()
    initialGroup.enter()
    fetchFriendList { friendListFetched, error in
        if let error = error {
            print("Error: \(error)")
            initialGroup.leave()
        } else if let friendListFetched = friendListFetched {
            friendList = friendListFetched
            initialGroup.leave()
        }
    }
    
    initialGroup.notify(queue: .main) {
        let group = DispatchGroup()
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
                    if friendList.contains(event.hostUID) {
                        eventGalleries.append(event)
                        print("Added")
                    }
                    else {
                        let innerGroup = DispatchGroup()
                        var add = false
                        for highlightID in event.highlights {
                            let highlightDocRef = db.collection("Posts").document(highlightID)
                            innerGroup.enter()
                            group.enter()
                            highlightDocRef.getDocument(completion: {d3, e3 in
                                if let d3 = d3, d3.exists {
                                    if let postUserID = d3.data()?["User"] as? String {
                                        if friendList.contains(postUserID) {
                                            add = true
                                        }
                                    }
                                }
                                innerGroup.leave()
                                group.leave()
                            })
                        }
                        innerGroup.notify(queue: .main) {
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
                    
                }
                group.leave()
            }
        
        group.notify(queue: .main) {
            completion(eventGalleries, nil)
        }
    }
}
