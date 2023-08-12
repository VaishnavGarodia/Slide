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
    @State private var errorMessage: String = ""
    @State private var registered: Bool
    init(registered: Bool) {
        _registered = State(initialValue: registered)
    }
    
    var body: some View {
        VStack {
            
            // Sign-In with Google Button
            Button(action: {
                googleSignIn(registered: false) { error in
                    // Handle the completion result
                    if error.isEmpty {
                        // User signed in successfully
                    } else {
                        self.errorMessage = error
                    }
                }
            }) {
                Image("google_logo")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .bubbleStyle(color: Color("OppositeColor"))
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
    }
}




struct GoogleButton_Previews: PreviewProvider {
    static var previews: some View {
        GoogleButton(registered: false)
    }
}
