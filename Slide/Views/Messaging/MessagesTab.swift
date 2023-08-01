//
//  MessagesTab.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

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

                var newRecentMessages = [String: [RecentMessage]]() // Temporary dictionary

                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    let data = change.document.data()
                    let message = RecentMessage(documentId: docId, data: data)

                    let otherUserId = message.fromId == uid ? message.toId : message.fromId

                    if newRecentMessages[otherUserId] == nil {
                        newRecentMessages[otherUserId] = [message]
                    } else {
                        newRecentMessages[otherUserId]?.append(message)
                    }
                })

                DispatchQueue.main.async {
                    self.recentMessages = newRecentMessages // Update the dictionary
                }
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

struct RecentMessage: Identifiable {
    var id: String { documentId }
    let documentId: String
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

struct MessagesTab: View {
    
    @State public var numGroups = 1
    @State public var searchMessages = ""
    @State private var username = ""
    
    public func formatTimestamp(_ timestamp: Timestamp) -> String {
        let currentDate = Date()
        let messageDate = timestamp.dateValue()
        
        let calendar = Calendar.current
        if calendar.isDateInToday(messageDate) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: messageDate)
        } else if calendar.isDate(messageDate, equalTo: currentDate, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day of the week
            return formatter.string(from: messageDate)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: messageDate)
        }
    }

    @ObservedObject private var vm = MainMessagesViewModel()

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "list.bullet")
                    .padding()
                    .imageScale(.large)
                Spacer()
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchMessages)
                }
                .padding()
                Spacer()
                NavigationLink(destination: AddFriendsView()) {
                    Image(systemName: "person.badge.plus")
                        .padding()
                        .imageScale(.large)
                }
                NavigationLink(destination: NewChat()) {
                    Image(systemName: "square.and.pencil")
                        .padding()
                        .imageScale(.large)
                }
            }
            .padding(.bottom, -10)
            .padding(.top, -10)

            ScrollView {
                VStack {
                    ForEach(vm.recentMessages.keys.sorted(), id: \.self) { chatUserId in
                        if let messages = vm.recentMessages[chatUserId], let recentMessage = messages.last {
                            NavigationLink(destination: ChatView(chatUser: ChatUser(uid: recentMessage.toId, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl))) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .frame(width: 50)
                                            .padding()
                                            .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        UserProfilePictures(photoURL: recentMessage.profileImageUrl, dimension: 50)
                                            .clipShape(Circle())
                                    }
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(recentMessage.toId)
                                            .padding(.leading, -10.0)
                                        Text(recentMessage.text)
                                            .foregroundColor(Color(.white))
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    Text(formatTimestamp(recentMessage.timestamp))
                                        .padding()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MessagesTab_Previews: PreviewProvider {
    static var previews: some View {
        MessagesTab()
    }
}
