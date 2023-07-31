//  searchUsersByUsername.swift
//  Slide
//  Created by Ethan Harianto on 7/30/23.

import Foundation
import FirebaseFirestore
import FirebaseAuth

func searchUsersByUsername(username: String, completion: @escaping ([UserData]) -> Void) {
    let user = Auth.auth().currentUser
    let query = db.collection("Users")
        .whereField("Username", isGreaterThanOrEqualTo: username)
        .whereField("Username", isLessThan: username + "z")
        .whereField("Username", isNotEqualTo: user?.displayName ?? "SimUser")
    query.getDocuments { snapshot, error in
        if let error = error {
            print("Error searching users: \(error.localizedDescription)")
            completion([])
            return
        }
        var users: [UserData] = []
        for document in snapshot?.documents ?? [] {
            if let username = document.data()["Username"] as? String,
               let photoURL = document.data()["ProfilePictureURL"] as? String,
               let incoming = document.data()["Incoming"] as? [String],
               let friends = document.data()["Friends"] as? [String]
            {
                let added = incoming.contains(user?.uid ?? "SimUser")
                let potential = UserData(
                    userID: document.documentID,
                    username: username,
                    photoURL: photoURL,
                    added: added
                )
                if !friends.contains(user?.uid ?? "SimUser") {
                    users.append(potential)
                }
            }
        }
        completion(users)
    }
}
