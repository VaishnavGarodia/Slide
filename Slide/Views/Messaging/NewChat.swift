// NewChat.swift
// Slide
// Created by Nidhish Jain on 7/21/23.

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct NewChat: View {
    @State public var numGroups = 1
    @State public var searchMessages = ""
    @State private var friendList: [(String, String)] = []
    @State private var idList: [String] = []
    func fetchFriendList() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let userDocumentRef = db.collection("Users").document(currentUserID)
        let dispatchGroup = DispatchGroup()
        // Step 1: Access the User document using the given document ID
        userDocumentRef.getDocument { document, _ in
            if let document = document, document.exists {
                let friendIdList = document.data()?["Friends"] as? [String] ?? []
                for friendId in friendIdList {
                    dispatchGroup.enter() // Enter the DispatchGroup before starting an asynchronous task
                    // Fetch username from the "Users" database using the userDocumentID
                    fetchUsername(for: friendId) { username, photoURL in
                        if let username = username, let photoURL = photoURL {
                            if !self.friendList.contains(where: { $0.0 == username }) {
                                friendList.append((username, photoURL))
                                idList.append(friendId)
                            }
                            dispatchGroup.leave() // Leave the DispatchGroup when the task is complete
                        }
                    }
                }
                self.friendList = friendList
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "list.bullet")
                    .padding()
                    .imageScale(.large)
                Spacer()
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("New Message", text: $searchMessages)
                }
                .padding()
                Spacer()
                NavigationLink(destination: MessagesTab()) {
                    Text("Cancel")
                        .padding()
                }
            }
            .padding(.bottom, -10)
            .padding(.top, -10)
            ScrollView {
                VStack {
                    HStack {
                        Text("Friends")
                            .padding()
                        Spacer()
                    }
                    ForEach(Array(friendList.enumerated()), id: \.element.0) { index, element in
                        let (friendId, photoURL) = element
                        VStack {
                            HStack {
                                NavigationLink(destination: ChatView(chatUser: ChatUser(uid: idList[index], email: "", profileImageUrl: photoURL))) {
                                    Text(friendId)
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }.onAppear { fetchFriendList() }.refreshable {
                fetchFriendList()
            }
        }
    }
}

struct NewChat_Previews: PreviewProvider {
    static var previews: some View {
        NewChat()
    }
}
