//
//  Authentication.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

let storage = Storage.storage()
let db = Firestore.firestore()

struct SignUp: View {
    @State public var email = ""
    @State public var password = ""
    @State public var confirmpass = ""
    @State public var errormessage = ""
    @State private var emailSwitch = false
    @State private var username = ""
    
    
    var body: some View {
        
        if emailSwitch {
            VStack {
                Image("logo")
                    .padding(.all, -120.0)
                
                Text("Please confirm your email.")
            }
            .padding()
            .transition(.slide)
        } else {
            
            VStack {
                Image("logo")
                    .padding(.all, -120.0)
                
                Text(errormessage)
                
                TextField("Username", text: $username)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                TextField("Email", text: $email)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                SecureField("Password", text: $password)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                SecureField("Confirm Password", text: $confirmpass)
                    .padding(12.0)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color("OppositeColor")))
                
                HStack {
                    Button(action: {signup() }) {
                        Text("Sign up")
                        Image(systemName: "mappin")
                    }
                }
                .padding(12.0)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.cyan))
                
                NavigationLink(destination: LogIn()) {
                    Text("Have an account?")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
    }
        func signup() {
            if password != confirmpass {
                errormessage = ("Passwords were not spelt the same.")
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if error != nil {
                        errormessage = (error?.localizedDescription ?? "")
                    } else if let result = result{
                        let changeRequest = result.user.createProfileChangeRequest()
                                changeRequest.displayName = username
                        addUser()
                    }
                }
            }
        }
        func addUser() {
            let usersRef = db.collection("users").document(username)
        usersRef.getDocument {(document, error) in
            if let document = document, document.exists {
        errormessage = ("Username taken.")
            } else {
                db.collection("users").document(username).setData([
                    "email": email,
                    "password": password,
                    "username": username
                    ])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        } else {
                            print("Document successfully written.")
                            emailSwitch.toggle()
                    }
                }
            }
        }
    }
}
            

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
