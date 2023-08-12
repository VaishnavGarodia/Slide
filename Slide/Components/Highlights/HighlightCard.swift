// HighlightCard.swift
// Slide
// Created by Ethan Harianto on 7/20/23.

import Kingfisher
import SwiftUI
import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

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
                            .onTapGesture {
                                selectedUser = UserData(userID: highlight.uid, username: highlight.username, photoURL: highlight.profileImageName)
                                profileView.toggle()
                            }
                        VStack(alignment: .leading) {
                            Text(highlight.username)
                                .foregroundColor(.white)
                            Text(highlight.highlightTitle)
                                .font(.caption)
                                .fontWeight(.thin)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 5)
                    .background(RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.black.opacity(0.5)))
                    .padding(5)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.white)
                            .imageScale(.medium)
                            .padding()
                            .background(Circle()
                                .foregroundColor(.black.opacity(0.5)))
                        Button(action: {
                            LikePost()
                            currentUserLiked.toggle()
                        }) {
                            Image(systemName: currentUserLiked ? "heart.fill" : "heart")
                                .foregroundColor(currentUserLiked ? .red : .white)
                                .imageScale(.medium)
                                .padding()
                                .background(Circle()
                                    .foregroundColor(.black.opacity(0.5)))
                        }
                    }
                    .padding(5)
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
        let eventDocRef = db.collection("Posts").document(postID)
        print("POST ID")
        print(postID)
        
        eventDocRef.getDocument { document, _ in
            if let document = document, document.exists {
                var likedUsersList = document.data()?["Liked Users"] as? [String] ?? []
                if likedUsersList.contains(currentUserID) {
                    likedUsersList.removeAll { $0 == currentUserID }
                }
                else {
                    likedUsersList.append(currentUserID)
                }
                eventDocRef.updateData(["Liked Users": likedUsersList])
                highlight.likedUsers = likedUsersList
            }
            else {
                print("User document not found!")
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
                .frame(width: 180, height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Spacer()
                Text(highlight.highlightTitle)
                    .padding(2) // Add some padding to increase the frame size
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10) // Add corner radius to make it rounded
            }
        }
        .padding()
    }
}
