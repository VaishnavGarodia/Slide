//
//  googleSignIn.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import Firebase
import Foundation
import GoogleSignIn
import UIKit

func googleSignIn(registered: Bool, completion: @escaping (String) -> Void) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        completion("Client ID not found.")
        return
    }
    
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let windowDelegate = scene.delegate as? UIWindowSceneDelegate,
       let window = windowDelegate.window,
       let rootViewController = window?.rootViewController
    {
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signResult, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            guard let gUser = signResult?.user,
                  let idToken = gUser.idToken
            else {
                completion("Failed to get user or ID token.")
                return
            }
            let email = gUser.profile?.email ?? ""
            let accessToken = gUser.accessToken
            
            if !email.hasSuffix("@stanford.edu") {
                completion("Slide isn't available at your school yet!")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            print("okay")
            
            // Use the credential to authenticate with Firebase
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    completion(error.localizedDescription)
                    return
                }
            }
            
            var errorMessage = ""
            let username = email.components(separatedBy: "@").first
            let password = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                errorMessage = addUserToDatabases(username: username!, email: email, password: password, google: true)
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    errorMessage = error?.localizedDescription ?? "no error"
                }
            }
                
            if errorMessage.isEmpty {
                print("no error")
                completion("") // No error, empty string
            } else {
                completion(errorMessage)
            }
        }
    } else {
        completion("Failed to get window or root view controller.")
    }
}
