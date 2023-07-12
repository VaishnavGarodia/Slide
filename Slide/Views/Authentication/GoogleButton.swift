//
//  GoogleSignInView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import Firebase
import GoogleSignIn
import SwiftUI

struct GoogleButton: View {
    @State private var buttonText: String
    @State private var errorMessage: String = ""
    
    init(text: String) {
        _buttonText = State(initialValue: text)
    }
    
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
                                        errorMessage = error.localizedDescription
                                        return
                                    }
                                    
                                    guard let user = signResult?.user,
                                          let idToken = user.idToken
                                    else {
                                        errorMessage = "Failed to get user or ID token."
                                        return
                                    }
                                    
                                    let accessToken = user.accessToken
                                    
                                    let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                                    
                                    // Use the credential to authenticate with Firebase
                                    Auth.auth().signIn(with: credential) { _, error in
                                        if let error = error {
                                            errorMessage = error.localizedDescription
                                            return
                                        }
                                        
                                        // Handle successful authentication
                                    }
                                }
                            }
                        }
                    }
                }
                
            }) {
                Text(buttonText)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
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

struct GoogleButton_Previews: PreviewProvider {
    static var previews: some View {
        GoogleButton(text: "Sign in with Google")
    }
}
