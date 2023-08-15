//  Profile View.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import Firebase
import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    // functions used: fetchCurrentFriendsCount
    @StateObject private var profileInfo = ProfileInfo()
    @State private var user = Auth.auth().currentUser
    @State private var tab = "Highlights"
    @State private var editProfilePic = false
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                HStack {
                    VStack(alignment: .center) {
                        Text("\(profileInfo.highlights.count)")
                        Text(profileInfo.highlights.count == 1 ? "Highlight" : "Highlights")
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    VStack {
                        Text("\(profileInfo.friendsCount)")
                        Text(profileInfo.friendsCount == 1 ? "Friend" : "Friends")
                    }
                    .padding(.trailing)
                }
                
                ZStack {
                    Color.accentColor
                        .clipShape(Circle())
                        .frame(width: 115, height: 115)
                    
                    Color.black
                        .clipShape(Circle())
                        .frame(width: 110, height: 110)
                    
                    ProfilePicture()
                }
            }
            
            Text(user?.displayName ?? "SimUser")
                .fontWeight(.semibold)
                .foregroundColor(.primary)

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
                    ProfileHighlightsView(highlightHolder: profileInfo)
                        .transition(.move(edge: .leading))
                } else {
                    ProfileEventsView()
                        .transition(.move(edge: .trailing))
                }
                Spacer()
            }
            .onAppear {
                fetchCurrentFriendsCount(highlightHolder: profileInfo)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
