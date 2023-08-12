//  MainMessagesViewModel.swift
//  Slide
//  Created by Ethan Harianto on 8/5/23.

import Firebase
import Foundation

class MainMessagesViewModel: ObservableObject {
    @Published var chatUser: ChatUser?
    @Published var recentMessages = [String: [RecentMessage]]() // Dictionary to store messages

    init() {
        fetchCurrentUser()
        fetchRecentMessages()
    }

    private func fetchRecentMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        db.collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }

                querySnapshot?.documentChanges.forEach { change in
                    let docId = change.document.documentID
                    let data = change.document.data()
                    let message = RecentMessage(documentId: docId, data: data)

                    let otherUserId = message.fromId == uid ? message.toId : message.fromId

                    if self.recentMessages[otherUserId] == nil {
                        self.recentMessages[otherUserId] = [message]
                    } else {
                        self.recentMessages[otherUserId]?.append(message)
                    }
                }
            }
    }

    func hideMessage(_ message: RecentMessage) {
        if let index = recentMessages[message.toId]?.firstIndex(where: { $0.documentId == message.documentId }) {
            recentMessages[message.toId]?.remove(at: index)
        }
    }

    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection("users")
            .document(uid).getDocument { snapshot, error in
                if let error = error {
                    print(error)
                    return
                }

                guard let data = snapshot?.data() else { return }
                let uid = data["uid"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let profileImageUrl = data["profileImageUrl"] as? String ?? ""

                self.chatUser = ChatUser(uid: uid, email: email, profileImageUrl: profileImageUrl)
            }
    }
}
