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
    @State private var highlights: [HighlightInfo] = []
    @State private var userListener = UserListener()
    @State private var tab = "Highlights"

    var body: some View {
        VStack {
            ProfilePicture()

            if let user = userListener.user {
                Text(user.displayName!)
                    .foregroundColor(.primary)
                    .padding()
            } else {
                Text("SimUser")
                    .foregroundColor(.primary)
                    .padding()
            }

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
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(highlights) { highlight in
                                SmallHighlightCard(highlight: highlight)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        fetchHighlights(for: userListener.user!.uid)
                    }
                }

                Spacer()
            }
        }
    }

    func fetchHighlights(for userID: String) {
        let postsCollectionRef = db.collection("Posts")

        postsCollectionRef.whereField("User", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching highlights: \(error.localizedDescription)")
                return
            }

            var newHighlights: [HighlightInfo] = []
            let dispatchGroup = DispatchGroup() // Create a DispatchGroup

            for document in snapshot?.documents ?? [] {
                if let caption = document.data()["ImageCaption"] as? String,
                   let imagePath = document.data()["PostImage"] as? String
                {
                    dispatchGroup.enter() // Enter the DispatchGroup before starting an asynchronous task

                    // Fetch username from the "Users" database using the userID
                    fetchUsername(for: userID) { username in
                        if let username = username {
                            let highlight = HighlightInfo(
                                imageName: imagePath, profileImageName: "ProfilePic2", username: username, highlightTitle: caption)
                            newHighlights.append(highlight)

                            dispatchGroup.leave() // Leave the DispatchGroup when the task is complete
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                // This block is called when all the tasks inside the DispatchGroup are completed
                self.highlights = newHighlights
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
