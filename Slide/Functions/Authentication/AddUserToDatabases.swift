//
//  AddUser.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

func addUserToDatabases(username: String, email: String, password: String, google: Bool) -> String {
    guard let user = Auth.auth().currentUser else {
        return "User is not signed in."
    }
    
    let uid = user.uid
    
    var errormessage = ""
    
    let usersRef = db.collection("Users").document(uid)
    let usernameRef = db.collection("Usernames").document(username)
    
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
                "Password": password,
                "Username": username,
                "ProfilePictureURL": "",
                "Phone Number" : "",
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
