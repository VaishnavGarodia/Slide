// ChatView.swift
// Slide
//
// Created by Nidhish Jain on 7/26/23.
//
import FirebaseAuth
import FirebaseFirestore
import MessageKit
import SwiftUI

struct ChatMessage: Identifiable {
    var id: String { documentId }
    let documentId: String
    let sender, recipient, text: String

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.sender = data["sender"] as? String ?? ""
        self.recipient = data["recipient"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
    }
}

class ChatViewModel: ObservableObject {
    let chatUser: ChatUser?
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    
    private func fetchMessages() {
        guard let sender = Auth.auth().currentUser?.uid else {
            return
        }
        guard let recipient = chatUser?.uid else { return }
        db.collection("messages")
            .document(sender)
            .collection(recipient)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                }
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    func handleSend() {
        guard let sender = Auth.auth().currentUser?.uid else {
            return
        }
        guard let recipient = chatUser?.uid else { return }
        let document = db.collection("messages")
            .document(sender)
            .collection(recipient)
            .document()
        let messageData = ["sender": sender, "recipient": recipient, "text": chatText, "timestamp": Timestamp()] as [String: Any]
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in Firestore: \(error)"
                return
            }
            self.persistRecentMessage()
            self.chatText = ""
            self.count += 1
        }
        let recipientDocument = db.collection("messages")
            .document(recipient)
            .collection(sender)
            .document()
        recipientDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in Firestore: \(error)"
                return
            }
        }
    }
    
    private func persistRecentMessage(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        guard let toId = self.chatUser?.uid else { return }
        let document = db.collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        let data = [
            "timestamp": Timestamp(),
            "text": self.chatText,
            "fromId": uid,
            "toId": toId,
            "profileImageUrl": chatUser?.profileImageUrl ?? "",
            "email": chatUser?.email ?? ""
        ] as [String : Any]
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                return
            }
        }
    }
    
    private func persistRecentMessageForRecipient() {
        guard let sender = Auth.auth().currentUser?.uid else {
            return
        }
        guard let recipient = chatUser?.uid else {
            return
        }

        let document = db.collection("recent_messages")
            .document(recipient)
            .collection("messages")
            .document(sender)

        let data = [
            "timestamp": Timestamp(),
            "text": self.chatText,
            "fromId": sender,
            "toId": recipient,
            "profileImageUrl": chatUser?.profileImageUrl ?? "",
            "email": chatUser?.email ?? ""
        ] as [String: Any]

        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message for recipient: \(error)"
                return
            }
        }
    }
    
    @Published var count = 0
}

struct ChatUser {
    let uid, email, profileImageUrl: String
}

extension Color {
    static let darkGray = Color(red: 0.17, green: 0.17, blue: 0.17)
}

struct ChatView: View {
    let chatUser: ChatUser?
    @State private var username = ""
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    static let emptyScrollToString = "Empty"
    
    @ObservedObject var vm: ChatViewModel
    
    var body: some View {
        ZStack {
            Text(vm.errorMessage)
        }
        .navigationTitle(username)
        .navigationBarTitleDisplayMode(.inline)
        
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    ForEach(vm.chatMessages) { message in
                        VStack {
                            if message.sender == Auth.auth().currentUser?.uid {
                                HStack {
                                    Spacer()
                                    HStack {
                                        Text(message.text)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            } else {
                                HStack {
                                    HStack {
                                        Text(message.text)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.darkGray)
                                    .cornerRadius(12)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                        }
                    }
                    HStack { Spacer() }
                        .id(Self.emptyScrollToString)
                        .onReceive(vm.$count) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                            }
                        }
                }
            }
        }
        .onAppear {
            fetchUsername(for: chatUser?.uid ?? "") { name, _ in
                username = name ?? ""
            }
        }
        
        HStack {
            Image(systemName: "photo")
            ZStack {
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button(action: {
                vm.handleSend()
            }) {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)
            .disabled(vm.chatText.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(chatUser: .init(uid: "", email: "", profileImageUrl: ""))
    }
}
