//
//  Authentication.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct LogIn: View {
    // initializaes variables to which email and password are linked to
    @State var email = ""
    @State var email2 = ""
    @State var password = ""
    @State var loggedIn = false
    @State var errormessage = ""
    @State var emailChange = false
    
    // body of View
    var body: some View {
        if loggedIn {
            MainView()
                .navigationBarBackButtonHidden()
        } else {
            VStack {
                    
                // logo with -120 pixel border
                Image("logo")
                    .padding(.all, -120.0)
                
                Text(errormessage)
                    
                // Email text field with rounded input field
                TextField("Email/Username", text: $email)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                    
                // Password text field with rounded input field
                SecureField("Password", text: $password)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                    
                // sign in button with rounded cyan border
                HStack {
                    Button(action: { login() }) {
                        Text("Log in")
                            
                        Image(systemName: "mappin")
                    }
                }
                .padding(12.0)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.cyan))
                
                NavigationLink(destination: SignUp()) {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
    }

    
    func login() {
        if  !emailChange {
            email2 = email
        }
        Auth.auth().signIn(withEmail: email2, password: password) { (result, error) in
            if let error = error {
                let err = error as NSError
                if let authErrorCode = AuthErrorCode.Code(rawValue: err.code) {
                    
                    switch authErrorCode {
                    case .invalidEmail:
                        let emailRef = db.collection("users").document(email)
                        emailRef.getDocument(source: .cache) { (document, error) in
                                if let document = document {
                                    email2 = document.get("email") as! String
                                    emailChange.toggle()
                                    login()
                                    } else {
                                        errormessage = "Invalid username"
                                    }
                                }
                        Auth.auth().signIn(withEmail: email2, password: password)
                        break
                    default:
                        errormessage = error.localizedDescription
                    }
                }
            } else {
                loggedIn.toggle()
            }
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn()
    }
}
