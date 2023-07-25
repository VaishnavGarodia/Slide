//
//  SignOut.swift
//  Slide
//
//  Created by Ethan Harianto on 7/25/23.
//

import Foundation
import FirebaseAuth

// signs out the current user
func signOut() {
    do {
        try Auth.auth().signOut()
    } catch let signOutError as NSError {
        print("Error signing out: %@", signOutError)
    }
}
