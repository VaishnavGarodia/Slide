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
    @State private var contactList = [ContactInfo]()
    
    var body: some View {
        VStack {
            Image("logo")
                .padding(.all, -120.0)
                
            Text(errorMessage)
                .foregroundColor(.red)
                
            VStack(alignment: .leading, spacing: 15) {
                Section("Username") {
                    TextField("Choose a username", text: $username)
                        .checkMarkTextField()
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .bubbleStyle(color: Color("OppositeColor"))
                        .onChange(of: username) { _ in
                            errorMessage = (username.contains(" ") ? "Your username can't include spaces." : "")
                        }
                }
                
                Section("Email") {
                    TextField("Enter a valid .edu address", text: $email)
                        .keyboardType(.emailAddress)
                        .checkMarkTextField()
                        .bubbleStyle(color: Color("OppositeColor"))
                        .onChange(of: email) { _ in
                            errorMessage = (email.contains(".edu") ? isEmailValid(email) : "")
                        }
                }
                
                Section("Password") {
                    PasswordField(password: $password, text: "Choose a password")
                        .checkMarkTextField()
                        .bubbleStyle(color: Color("OppositeColor"))
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
            }
            .filledBubble()
                
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                NavigationLink(destination: LogIn().transition(.move(edge: .trailing))) {
                    Text("Log In")
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                }
                .navigationBarBackButtonHidden(true)
            }
            
            GoogleButton(registered: false)
        }
        .padding()
    }
}
            
struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Register()
    }
}
