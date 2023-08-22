//  PasswordView.swift
//  Slide
//  Created by Ethan Harianto on 8/20/23.

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct PasswordView: View {
    var user = Auth.auth().currentUser
    @State private var passwordSet = false
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var success = false
    @State private var changePassword = false

    var body: some View {
        VStack(alignment: .center) {
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            if success {
                Text("Success")
                    .bubbleStyle(color: .primary)
            } else if passwordSet {
                if changePassword {
                    Text("Set a password")
                        .foregroundColor(.secondary)
                    TextField("Enter a password", text: $password)
                        .checkMarkTextField()
                        .bubbleStyle(color: .primary)
                        .onChange(of: password, perform: { newText in
                            errorMessage = isPasswordValid(newText)
                        })
                    Button {
                        setPassword(password: password) { error in
                            if error != "Success" {
                                errorMessage = error
                            } else {
                                errorMessage = ""
                                password = ""
                                success = true
                            }
                        }
                    } label: {
                        Text("Submit Password")
                            .filledBubble()
                    }
                } else {
                    Text("Confirm Password")
                    TextField("Enter your password", text: $password)
                        .checkMarkTextField()
                        .bubbleStyle(color: .primary)
                    Button { correctPassword(password: password) { error in
                        if error != "true" {
                            if error == "false" {
                                errorMessage = "Wrong password."
                            } else {
                                errorMessage = error
                            }
                        } else {
                            withAnimation {
                                errorMessage = ""
                                password = ""
                                changePassword.toggle()
                            }
                        }
                    }} label: {
                        Text("Submit")
                            .filledBubble()
                    }
                }

            } else {
                Text("You don't have a password set")
                    .foregroundColor(.red)
                TextField("Enter a password", text: $password)
                    .checkMarkTextField()
                    .bubbleStyle(color: .primary)
                    .onChange(of: password, perform: { newText in
                        errorMessage = isPasswordValid(newText)
                    })
                Button {
                    setPassword(password: password) { error in
                        if error != "Success" {
                            errorMessage = error
                        } else {
                            errorMessage = ""
                            password = ""
                            passwordSet = true
                        }
                    }
                } label: {
                    Text("Submit Password")
                        .filledBubble()
                }
            }
        }
        .onAppear {
            isGoogleUser(email: user?.email ?? "") { google, _ in
                passwordSet = !google
            }
            password = ""
            errorMessage = ""
            success = false
            changePassword = false
        }
    }

    func setPassword(password: String, completion: @escaping (String) -> Void) {
        let user = Auth.auth().currentUser
        let usernameRef = db.collection("Usernames").document(user?.displayName ?? "")
        usernameRef.getDocument { document, error in
            if let error = error {
                completion("Error checking username: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                var userData: [String: Any] = [
                    "Google": false
                ]
                usernameRef.updateData(userData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    }
                }
                user!.updatePassword(to: password) { error in
                    print(error?.localizedDescription ?? "")
                }
                let userRef = db.collection("Users").document(user?.uid ?? "")
                userData = [
                    "Password": password
                ]
                userRef.updateData(userData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    }
                }
                completion("Success")
            }
        }
    }

    func correctPassword(password: String, completion: @escaping (String) -> Void) {
        let userRef = db.collection("Users")
            .document(user?.uid ?? "")

        userRef.getDocument { document, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            if let document = document {
                // Access the "google" field's value from the document data
                if let passwordField = document.data()?["Password"] as? String {
                    // Return true if the "google" field is true
                    completion(String(password == passwordField))
                } else {
                    // If "google" field is missing or not a Bool value, return false
                    completion("shit")
                }
            } else {
                // User not found, return false
                completion("fook")
            }
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView()
    }
}
