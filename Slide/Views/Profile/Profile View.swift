//
//  Profile View.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import Firebase
import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @StateObject private var highlightHolder = HighlightHolder()
    let user = Auth.auth().currentUser
    @State private var tab = "Highlights"
    
    var body: some View {
        VStack {
            UserProfilePictures(photoURL: user?.photoURL?.absoluteString ?? "", dimension: 125)

            Text(user?.displayName ?? "SimUser")
                .foregroundColor(.primary)
                .padding()

            VStack(alignment: .center) {
                HStack {
                    Button {
                        tab = "Highlights"
                    } label: {
                        if tab == "Highlights" {
                            Text("Highlights").underlineGradient()
                        } else {
                            Text("Highlights").emptyBubble()
                        }
                    }

                    Button {
                        tab = "Events"
                    } label: {
                        if tab == "Events" {
                            Text("Events").underlineGradient()
                        } else {
                            Text("Events").emptyBubble()
                        }
                    }
                }
                .padding()

                if tab == "Highlights" {
                    ProfileHighlightsView(highlightHolder: highlightHolder)
                        .transition(.move(edge: .leading))
                } else {
                    ProfileEventsView()
                        .transition(.move(edge: .trailing))
                }
                Spacer()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
