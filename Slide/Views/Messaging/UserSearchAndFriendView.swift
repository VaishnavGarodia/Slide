//
//  UserSearchAndFriendView.swift
//  Slide
//
//  Created by Thomas on 6/29/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct tempUserOtherData: Codable {
    let userID: String
    let username: String
    let phone: String
    let password: String
    let email: String
    // Other properties and methods as needed
}


class FirebaseManager {
    let db = Firestore.firestore()
    
    // Function to search for users by username
    func searchUsersByUsername(username: String, completion: @escaping ([tempUserOtherData]) -> Void) {
        let query = db.collection("Users")
            .whereField("Username", isGreaterThanOrEqualTo: username)
            .whereField("Username", isLessThan: username + "z")
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error searching users: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var users: [tempUserOtherData] = []
            
            for document in snapshot?.documents ?? [] {
                if let username = document.data()["Username"] as? String,
                   let phone = document.data()["Phone"] as? String,
                   let password = document.data()["Password"] as? String,
                   let email = document.data()["Email"] as? String {
                    let user = tempUserOtherData(
                                    userID: document.documentID,
                                    username: username,
                                    phone: phone,
                                    password: password,
                                    email: email)
                    users.append(user)
                }
            }
            
            completion(users)
        }
    }

}

struct UserSearchAndFriendView: View {
    @State private var searchQuery = ""
    @State private var searchResults: [tempUserOtherData] = []
    
    @State private var selectedUser: tempUserOtherData? = nil
    @State private var showingConfirmationDialog = false
    
    @State private var showPendingFriendRequests = false
    @State private var pendingFriendRequests: [tempUserOtherData] = []
    
    let firebaseManager = FirebaseManager()
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchQuery, onEditingChanged: { _ in
                searchUsers()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            List(searchResults, id: \.userID) { user in
                Text(user.username)
                    .onTapGesture {
                        selectedUser = user
                        showingConfirmationDialog = true
                    }
            }
            .alert(isPresented: $showingConfirmationDialog) {
                Alert(
                    title: Text("Send Friend Request"),
                    message: Text("Do you want to send a friend request to \(selectedUser?.username ?? "")?"),
                    primaryButton: .default(Text("Send"), action: {
                        sendFriendRequest()
                    }),
                    secondaryButton: .cancel()
                )
            }
            
            if searchQuery.isEmpty {
                Button(action: {
                    showPendingFriendRequests.toggle()
                    fetchPendingFriendRequests()
                }) {
                    Text(showPendingFriendRequests ? "Hide Pending Requests" : "Show Pending Requests")
                }
                .padding()
                
                if showPendingFriendRequests {
                    List(pendingFriendRequests, id: \.userID) { user in
                        Text(user.username)
                            .onTapGesture {
                                confirmFriendship(with: user)
                            }
                            .foregroundColor(.white)
                    }
                }
            } else {
                List(searchResults, id: \.userID) { user in
                    Text(user.username)
                        .onTapGesture {
                            selectedUser = user
                            showingConfirmationDialog = true
                        }
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    func searchUsers() {
        firebaseManager.searchUsersByUsername(username: searchQuery) { users in
            DispatchQueue.main.async {
                self.searchResults = users
            }
        }
    }
    
    func sendFriendRequest() {
        guard let currentUserID = Auth.auth().currentUser?.displayName,
              let selectedUserID = selectedUser?.userID else {
            return
        }
        
        let friendshipsCollection = db.collection("Friendships")
        
        let friendshipData: [String: Any] = [
            "User1": currentUserID,
            "User2": selectedUserID,
            "IsConfirmed1": true,
            "IsConfirmed2": false,
        ]
        
        friendshipsCollection.addDocument(data: friendshipData) { error in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
                return
            }
            
            // Friend request sent successfully
            print("Friend request sent!")
        }
    }
    
    func fetchPendingFriendRequests() {
        guard let currentUserID = Auth.auth().currentUser?.displayName else {
            return
        }
        
        let friendshipsCollection = firebaseManager.db.collection("Friendships")
        
        friendshipsCollection
            .whereField("User2", isEqualTo: currentUserID)
            .whereField("IsConfirmed2", isEqualTo: false)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching pending friend requests: \(error.localizedDescription)")
                    return
                }
                
                var pendingRequests: [tempUserOtherData] = []
                
                for document in snapshot?.documents ?? [] {
                    if let user1ID = document.data()["User1"] as? String {
                        // Fetch the details of the user who sent the friend request
                        fetchUserDetails(userID: user1ID) { user in
                            pendingRequests.append(user)
                        }
                    }
                }
                
                self.pendingFriendRequests = pendingRequests
            }
        return
    }
    
    func fetchUserDetails(userID: String, completion: @escaping (tempUserOtherData) -> Void) {
        db.collection("Users").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }
            
            if let document = document,
               let username = document.data()?["Username"] as? String,
               let phone = document.data()?["Phone"] as? String,
               let password = document.data()?["Password"] as? String,
               let email = document.data()?["Email"] as? String {
                let user = tempUserOtherData(userID: userID,
                                username: username,
                                phone: phone,
                                password: password,
                                email: email)
                completion(user)
            }
        }
    }
    
    func confirmFriendship(with user: tempUserOtherData) {
        let currentUserID = Auth.auth().currentUser?.uid
        let selectedUserID = user.userID
        
        let friendshipsCollection = db.collection("Friendships")
        
        friendshipsCollection
            .whereField("User1", isEqualTo: currentUserID)
            .whereField("User2", isEqualTo: selectedUserID)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error confirming friendship: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    return
                }
                
                let friendshipID = document.documentID
                
                friendshipsCollection.document(friendshipID).updateData([
                    "IsConfirmed1": true,
                    "IsConfirmed2": true
                ]) { error in
                    if let error = error {
                        print("Error confirming friendship: \(error.localizedDescription)")
                    } else {
                        print("Friendship confirmed!")
                        fetchPendingFriendRequests()
                    }
                }
            }
    }

}


struct UserSearchAndFriendView_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchAndFriendView()
    }
}

