// HighlightCard.swift
// Slide
// Created by Ethan Harianto on 7/20/23.

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Kingfisher
import SwiftUI
import UIKit

struct HighlightCard: View {
    let user = Auth.auth().currentUser
    @State var highlight: HighlightInfo
    @State private var currentUserLiked: Bool = false
    @Binding var selectedUser: UserData?
    @Binding var profileView: Bool

    var body: some View {
        ZStack {
            HighlightImage(imageURL: URL(string: highlight.imageName)!)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 15))
            VStack {
                HStack {
                    HStack {
                        UserProfilePictures(photoURL: highlight.profileImageName, dimension: 35)
                            .padding(.trailing, -5)
                            .onTapGesture {
                                selectedUser = UserData(userID: highlight.uid, username: highlight.username, photoURL: highlight.profileImageName)
                                profileView.toggle()
                            }
                        VStack(alignment: .leading) {
                            Text(highlight.username)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .onTapGesture {
                                    selectedUser = UserData(userID: highlight.uid, username: highlight.username, photoURL: highlight.profileImageName)
                                    profileView.toggle()
                                }
                            if !highlight.highlightTitle.isEmpty {
                                Text(highlight.highlightTitle)
                                    .font(.caption)
                                    .fontWeight(.thin)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(BlurView(style: .systemMaterial).cornerRadius(15))
                    .padding()
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        LikePost()
                        withAnimation {
                            currentUserLiked.toggle()
                        }
                    }) {
                        VStack {
                            Image(systemName: currentUserLiked ? "heart.fill" : "heart")
                            Text("\(highlight.likedUsers.count)")
                                .font(.caption)
                        }
                        .foregroundColor(currentUserLiked ? .accentColor : .white)
                        .padding()
                        .background(BlurView(style: .systemMaterial).clipShape(Circle()))
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            currentUserLiked = isCurUserLiking()
        }
    }

    func isCurUserLiking() -> Bool {
        guard let currentUserID = user?.uid else {
            return false
        }
        return highlight.likedUsers.contains(currentUserID)
    }

    func LikePost() {
        // 1. Add currentUserID to currentUserLiked and update likedUsers in highlight
        guard let currentUserID = user?.uid else {
            return
        }
        // 2. Update the corresponding post in the database
        let postID = highlight.postID
        let postRef = db.collection("Posts").document(postID)
        print("POST ID")
        print(postID)

        postRef.getDocument { document, _ in
            if let document = document, document.exists {
                var likedUsersList = document.data()?["Liked Users"] as? [String] ?? []
                if likedUsersList.contains(currentUserID) {
                    likedUsersList.removeAll { $0 == currentUserID }
                }
                else {
                    likedUsersList.append(currentUserID)
                }
                postRef.updateData(["Liked Users": likedUsersList])
                highlight.likedUsers = likedUsersList
            } else {
                print("Event document not found!")
            }
        }
    }
}

struct SmallHighlightCard: View {
    var highlight: HighlightInfo
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: highlight.imageName))
                .resizable()
                .fade(duration: 0.25)
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width / 2.25, height: UIScreen.main.bounds.width / 2.25)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(highlight.highlightTitle)
                .padding(2)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
        }
    }
}
