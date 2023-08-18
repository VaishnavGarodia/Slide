//
//  EmailSignUp.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import SwiftUI

struct Register: View {
    @State public var email = ""
    @State public var password = ""
    @State public var errorMessage = ""
    @State private var username = ""
    @Binding var logIn: Bool
    
    var body: some View {
        ZStack {
            ProgressIndicator(numDone: 1)
                .padding(.bottom, 50)
            VStack {
                VStack {
                    Image("logo")
                        
                    Text(errorMessage)
                        .foregroundColor(.red)
                        
                    VStack(alignment: .leading, spacing: 15) {
                        Section("Username") {
                            TextField("Choose a username", text: $username)
                                .checkMarkTextField()
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .bubbleStyle(color: .primary)
                                .onChange(of: username) { _ in
                                    errorMessage = (username.contains(" ") ? "Your username can't include spaces." : "")
                                }
                        }
                        
                        Section("Email") {
                            TextField("Enter a valid .edu address", text: $email)
                                .keyboardType(.emailAddress)
                                .checkMarkTextField()
                                .bubbleStyle(color: .primary)
                                .onChange(of: email) { _ in
                                    errorMessage = (email.contains(".edu") ? isEmailValid(email) : "")
                                }
                        }
                        
                        Section("Password") {
                            PasswordField(password: $password, text: "Choose a password")
                                .checkMarkTextField()
                                .bubbleStyle(color: .primary)
                                .onChange(of: password, perform: { newText in
                                    errorMessage = isPasswordValid(newText)
                                })
                        }
                    }
                    
                    Button(action: {
                        createFirebaseAccount(email: email, password: password, username: username) { error in
                            if !error.isEmpty {
                                errorMessage = error
                            }
                        }
                    }) {
                        Text("Create Account")
                            .filledBubble()
                    }
                }
                .padding()
                AccountCreationBottom(text: "Already have an account?", buttonText: "Log In", logIn: $logIn)
            }
        }
    }
}
            
struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Register(logIn: .constant(false))
    }
}
