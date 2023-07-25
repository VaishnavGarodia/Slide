//
//  createFirebaseAccount.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import FirebaseAuth
import Foundation

func createFirebaseAccount(email: String, password: String, username: String, completion: @escaping (String) -> Void) {
    if email.isEmpty || username.isEmpty || password.isEmpty {
        completion("Oops, you did not fill out all the fields.")
    }

    if email.hasSuffix("@stanford.edu") {
        completion("Slide isn't available at your school yet!")
    }

    Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            completion(error.localizedDescription)
        } else if let result = result {
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error committing profile changes: \(error)")
                }
            }
            let errorMessage = addUserToDatabases(username: username, email: email, password: password, google: false)
            completion(errorMessage)
        }
    }
}
