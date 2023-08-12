//  Profile View.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import Firebase
import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    // functions used: fetchUserData (fetches friend count)
    @StateObject private var highlightHolder = HighlightHolder()
    @State private var user = Auth.auth().currentUser
    @State private var tab = "Highlights"
    @State private var editProfilePic = false
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                HStack {
                    VStack(alignment: .center) {
                        Text("\(highlightHolder.highlights.count)")
                        Text(highlightHolder.highlights.count == 1 ? "Highlight" : "Highlights")
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    VStack {
                        Text("\(highlightHolder.friendsCount)")
                        Text(highlightHolder.friendsCount == 1 ? "Friend" : "Friends")
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
                    ProfileHighlightsView(highlightHolder: highlightHolder)
                        .transition(.move(edge: .leading))
                } else {
                    ProfileEventsView()
                        .transition(.move(edge: .trailing))
                }
                Spacer()
            }
            .onAppear {
                fetchUserData()
            }
        }
    }
    
    private func fetchUserData() {
        guard let uid = user?.uid else { return }
            
        // Fetch user data from Firestore using the uid
        db.collection("Users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }
                
            if let data = snapshot?.data(), let friendsCount = data["Friends"] as? [String] {
                highlightHolder.friendsCount = friendsCount.count
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
