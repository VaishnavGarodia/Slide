
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
        guard let recipient = chatUser?.uid else { return
        }
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
                        self.chatMessages.append(.init(documentId:
                                                        change.document.documentID, data: data))
                    }
                }
            }
    }
    func handleSend() {
        guard let sender = Auth.auth().currentUser?.uid else {
            return
        }
        guard let recipient = chatUser?.uid else { return
        }
        let document =
        db.collection("messages")
            .document(sender)
            .collection(recipient)
            .document()
        let messageData = ["sender": sender, "recipient": recipient, "text": chatText, "timestamp": Timestamp()] as [String: Any]
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in Firestore: \(error)"
                return
            }
            self.chatText = ""
        }
        let recipientDocument =
        db.collection("messages")
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
}
struct ChatUser {
    let uid, email, profileImageUrl: String
}
struct ChatView: View {
    
    let chatUser: ChatUser?
    @State private var username = ""
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    @ObservedObject var vm: ChatViewModel
    var body: some View {
        
        
        VStack {
            HStack {
                Text(username)
                    .padding()
                Spacer()
            }
            .padding(.bottom, -10)
            .padding(.top, -10)
            ScrollView {
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
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        } else {
                            HStack {
                                Spacer()
                                HStack {
                                    Text(message.text)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(8)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
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
