//
//  AddUser.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

// Don't save the password man...
//func addUserToDatabases(username: String, email: String, password: String, google: Bool, profilePic: String) -> String {
func addUserToDatabases(username: String, email: String, google: Bool, profilePic: String) -> String {
    guard let user = Auth.auth().currentUser else {
        return "User is not signed in."
    }
    
    let uid = user.uid
    
    var errormessage = ""
    
    
    let usersRef = db.collection("Users").document(uid)
    let usernameRef = db.collection("Usernames").document(username.lowercased())
    
    usersRef.getDocument { document, error in
        if let error = error {
            print("Error fetching document: \(error)")
            return
        }
        if let document = document, document.exists {
            errormessage = "Username taken."
        } else {
            let userData: [String: Any] = [
                "Email": email,
//                For the love of god why would we save the password...
//                "Password": password,
                "Username": username.lowercased(),
                "ProfilePictureURL": profilePic ,
                "Phone Number" : "",
                "Incoming": [String](),
                "Outgoing": [String](),
                "Friends": [String](),
                "Blocked": [String]()
            ]
            usersRef.setData(userData) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                    errormessage = error.localizedDescription
                }
            }
        }
    }
    
    usernameRef.getDocument { document, error in
        if let error = error {
            print("Error fetching document: \(error)")
            return
        }
        if let document = document, document.exists {
            errormessage = "Username taken."
        } else {
            let data: [String: Any] = [
                "Email": email,
                "Google": google,
            ]
            usernameRef.setData(data) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                    errormessage = error.localizedDescription
                }
            }
        }
    }
    
    return errormessage
}
