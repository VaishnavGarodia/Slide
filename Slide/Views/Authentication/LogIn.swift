//
//  Authentication.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import Firebase
import FirebaseFirestore
import SwiftUI

struct LogIn: View {
    // initializes variables to which email and password are linked to
    @State var email = ""
    @State var password = ""
    @State var errorMessage = ""
    @Binding var logIn: Bool
    
    // body of View
    var body: some View {
        VStack {
            VStack {
                // logo with -120 pixel border
                Image("logo")
                    .padding(.all, -120.0)
                    
                Text(errorMessage)
                    .foregroundColor(.red)
                        
                VStack(alignment: .leading, spacing: 15) {
                    // Email text field with rounded input field
                    Section("Username") {
                        TextField("Enter your email/username", text: $email)
                            .checkMarkTextField()
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .bubbleStyle(color: Color("OppositeColor"))
                            .onChange(of: email) { _ in
                                isGoogleUser(email: email) { isGoogleUser, error in
                                    if let error = error {
                                        // Handle the error
                                        print("Error: \(error.localizedDescription)")
                                    } else {
                                        if isGoogleUser {
                                            errorMessage = "This email was registered using Google. Please use the Google button below to log in."
                                        } else {
                                            print("The user is not a Google user.")
                                        }
                                    }
                                }

                            }
                        
                    }
                    
                    // Password text field with rounded input field
                    Section("Password") {
                        PasswordField(password: $password, text: "Enter your password")
                            .checkMarkTextField()
                            .bubbleStyle(color: Color("OppositeColor"))
                    }
                }
                                    
                // sign in button with rounded cyan border
                Button {
                    login(email: email, password: password) { error in
                        errorMessage = error
                    }
                } label: {
                    Text("Log In").filledBubble()
                }
                
            }
            .padding()
            AccountCreationBottom(text: "Don't have an account?", buttonText: "Sign Up", logIn: $logIn)
        }
       
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn(logIn: .constant(true))
    }
}
