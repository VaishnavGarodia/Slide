//
//  GoogleSignInView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import SwiftUI
import GoogleSignIn
import Firebase

struct GoogleSignInButton: View {
    var body: some View {
        VStack {
            // Add your other UI components here

            // Sign-In with Google Button
            Button(action: {
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                let config = GIDConfiguration(clientID: clientID)
                
                GIDSignIn.sharedInstance.configuration = config
                
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    if let windowDelegate = scene.delegate as? UIWindowSceneDelegate {
                        if let window = windowDelegate.window {
                            if let rootViewController = window?.rootViewController {
                                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signResult, error in
                                    if let error = error {
                                        // Handle error
                                        return
                                    }
                                    
                                    guard let user = signResult?.user,
                                          let idToken = user.idToken else {
                                        // Handle missing user or ID token
                                        return
                                    }
                                    
                                    let accessToken = user.accessToken
                                    
                                    let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                                    
                                    // Use the credential to authenticate with Firebase
                                }
                            }
                        }
                    }
                }
                
            }) {
                Text("Sign in with Google")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

struct GoogleSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInButton()
    }
}


extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        

        return root
    }
}
