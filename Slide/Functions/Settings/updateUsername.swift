//
//  updateUsername.swift
//  Slide
//
//  Created by Ethan Harianto on 7/26/23.
//

import Foundation

func updateUsername(username: String, completion: @escaping (String) -> Void) {
    let usernameRef = db.collection("Usernames").document(username)
    usernameRef.getDocument { document, error in
        if let error = error {
            completion("Error checking username: \(error.localizedDescription)")
            return
        }
        
        if let document = document, document.exists {
            // The username is already taken, handle this scenario (e.g., show an error message)
            completion("")
        } else {
            // The username is available, update the display name
            let changeRequest = user!.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    completion("Error updating display name: \(error.localizedDescription)")
                } else {
                    // Now the display name is updated, call the completion handler with the username
                    completion("")
                }
            }
        }
    }
}
