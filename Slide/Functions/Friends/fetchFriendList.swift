//
//  fetchFriendList.swift
//  Slide
//
//  Created by Thomas on 9/13/23.
//

import Foundation
import Firebase

 func fetchFriendList(completion: @escaping ([String]?, Error?) -> Void) {
    let user = Auth.auth().currentUser
    guard let currentUserID = user?.uid else {
        completion(nil, NSError(domain: "YourAppErrorDomain", code: 401, userInfo: ["message": "User not authenticated."]))
        return
    }

    var friendList: [String] = []

    let userDocumentRef = db.collection("Users").document(currentUserID)
    let group = DispatchGroup()
    
    group.enter()
    userDocumentRef.getDocument(completion: { d2, _ in
        if let d2 = d2, d2.exists {
            if let tempFriendsArray = d2.data()?["Friends"] as? [String] {
                friendList = tempFriendsArray
            }
        }
        group.leave()
    })
    
    group.notify(queue: .main) {
        completion(friendList, nil)
    }

}
