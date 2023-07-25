//
// UserSearchAndFriendView.swift
// Slide
//
// Created by Thomas on 6/29/23.
//
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct tempUserOtherData: Codable {
    let userID: String
    let username: String
    let password: String
    let email: String
    // Other properties and methods as needed
}

struct UserSearchAndFriendView: View {
    @State private var searchQuery = ""
    @State private var searchResults: [tempUserOtherData] = []
    @State private var selectedUser: tempUserOtherData? = nil
    @State private var showingConfirmationDialog = false
    @State private var showPendingFriendRequests = false
    @State private var pendingFriendRequests: [tempUserOtherData] = []
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
                    .foregroundColor(.white)
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
                                confirmFriendship(u1: Auth.auth().currentUser?.uid ?? "", u2: user.userID)
                            }
                            .foregroundColor(.white)
                    }
                }
            }
            else {
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

    func searchUsersByUsername(username: String, completion: @escaping ([tempUserOtherData]) -> Void) {
        let query = db.collection("Users")
            .whereField("Username", isGreaterThanOrEqualTo: username)
            .whereField("Username", isLessThan: username + "z")
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error searching users: \(error.localizedDescription)")
                completion([])
                return
            }
            var users: [tempUserOtherData] = []
            for document in snapshot?.documents ?? [] {
                if let username = document.data()["Username"] as? String,
                   let password = document.data()["Password"] as? String,
                   let email = document.data()["Email"] as? String
                {
                    let user = tempUserOtherData(
                        userID: document.documentID,
                        username: username,
                        password: password,
                        email: email
                    )
                    users.append(user)
                }
            }
            completion(users)
        }
    }

    func searchUsers() {
        searchUsersByUsername(username: searchQuery) { users in
            DispatchQueue.main.async {
                self.searchResults = users
            }
        }
    }

    func sendFriendRequest() {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let selectedUserID = selectedUser?.userID
        else {
            return
        }
        // First update the outgoing request
        let currentUserDocumentRef = db.collection("Users").document(currentUserID)
        // Step 1: Access the User document using the given document ID
        currentUserDocumentRef.getDocument { document, error in
            if let document = document, document.exists {
                let incomingList = document.data()?["Incoming"] as? [String] ?? []
                if incomingList.contains(selectedUserID) {
                    confirmFriendship(u1: currentUserID, u2: selectedUserID)
                }
                else {
                    var outgoingList = document.data()?["Outgoing"] as? [String] ?? []
                    // Step 2: Add the new string to the list
                    outgoingList.append(selectedUserID)
                    // Step 3: Update the User document with the modified "Outgoing" field
                    currentUserDocumentRef.updateData(["Outgoing": outgoingList]) { error in
                        if let error = error {
                            print("Error updating Outgoing field: \(error)")
                        }
                        else {
                            print("Outgoing field updated successfully!")
                        }
                    }
                }
            }
            else {
                print("User document not found!")
            }
        }
        // Now update the incoming request
        let selectedUserDocumentRef = db.collection("Users").document(selectedUserID)
        selectedUserDocumentRef.getDocument { document, error in
            if let document = document, document.exists {
                let outgoingList = document.data()?["Outgoing"] as? [String] ?? []
                if outgoingList.contains(currentUserID) {
                    confirmFriendship(u1: currentUserID, u2: selectedUserID)
                }
                else {
                    var incomingList = document.data()?["Incoming"] as? [String] ?? []
                    // Step 2: Add the new string to the list
                    incomingList.append(currentUserID)
                    // Step 3: Update the User document with the modified "Outgoing" field
                    selectedUserDocumentRef.updateData(["Incoming": incomingList]) { error in
                        if let error = error {
                            print("Error updating Outgoing field: \(error)")
                        }
                        else {
                            print("Outgoing field updated successfully!")
                        }
                    }
                }
            }
            else {
                print("User document not found!")
            }
        }
    }

    func fetchPendingFriendRequests() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let userDocumentRef = db.collection("Users").document(currentUserID)
        var pendingRequests: [tempUserOtherData] = []
        
        let group = DispatchGroup() // Create a DispatchGroup
        
        // Step 1: Access the User document using the given document ID
        userDocumentRef.getDocument { document, _ in
            if let document = document, document.exists {
                let incomingList = document.data()?["Incoming"] as? [String] ?? []
                for otherID in incomingList {
                    group.enter() // Enter the DispatchGroup before starting each fetchUserDetails call
                    fetchUserDetails(userID: otherID) { userDetails in
                        if let userDetails = userDetails {
                            // Handle userDetails if it's not nil
                            pendingRequests.append(userDetails)
                            print("???")
                            print(userDetails)
                            print(pendingRequests)
                        }
                        group.leave() // Leave the DispatchGroup after the fetchUserDetails call is completed
                    }
                }
                
                group.notify(queue: .main) {
                    // This closure will be called when all fetchUserDetails calls are completed
                    print("All fetchUserDetails calls completed")
                    print(pendingRequests)
                    self.pendingFriendRequests = pendingRequests
                }
            }
        }
    }


    func fetchUserDetails(userID: String, completion: @escaping (tempUserOtherData?) -> Void) {
        let db = Firestore.firestore()
        db.collection("Users").document(userID).getDocument { document, error in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                completion(nil) // Call completion with nil in case of an error
                return
            }
            
            // Check if the document exists and contains the required fields
            if let document = document,
               let username = document.data()?["Username"] as? String,
               let password = document.data()?["Password"] as? String,
               let email = document.data()?["Email"] as? String
            {
                let userDetails = tempUserOtherData(userID: userID, username: username, password: password, email: email)
                completion(userDetails)
            } else {
                completion(nil) // Call completion with nil if document is missing required fields
            }
        }
    }


    func confirmFriendship(u1: String, u2: String) {
        if u1 == "" || u2 == "" {
            return
        }
        let db = Firestore.firestore()
        // First update the first user
        let u1DocRef = db.collection("Users").document(u1)
        // Step 1: Access the User document using the given document ID
        u1DocRef.getDocument { document, _ in
            if let document = document, document.exists {
                var incomingList = document.data()?["Incoming"] as? [String] ?? []
                var outgoingList = document.data()?["Outgoing"] as? [String] ?? []
                var friendList = document.data()?["Friends"] as? [String] ?? []
                if let index = incomingList.firstIndex(of: u2) {
                    incomingList.remove(at: index)
                }
                if let index = outgoingList.firstIndex(of: u2) {
                    outgoingList.remove(at: index)
                }
                friendList.append(u2)
                u1DocRef.updateData(["Friends": friendList])
                u1DocRef.updateData(["Outgoing": outgoingList])
                u1DocRef.updateData(["Incoming": incomingList])
            }
            else {
                print("User document not found!")
            }
        }
        // Now update user2
        let u2DocRef = db.collection("Users").document(u2)
        // Step 1: Access the User document using the given document ID
        u2DocRef.getDocument { document, _ in
            if let document = document, document.exists {
                var incomingList = document.data()?["Incoming"] as? [String] ?? []
                var outgoingList = document.data()?["Outgoing"] as? [String] ?? []
                var friendList = document.data()?["Friends"] as? [String] ?? []
                if let index = incomingList.firstIndex(of: u1) {
                    incomingList.remove(at: index)
                }
                if let index = outgoingList.firstIndex(of: u1) {
                    outgoingList.remove(at: index)
                }
                friendList.append(u2)
                u2DocRef.updateData(["Friends": friendList])
                u2DocRef.updateData(["Outgoing": outgoingList])
                u2DocRef.updateData(["Incoming": incomingList])
            }
            else {
                print("User document not found!")
            }
        }
    }
}

struct UserSearchAndFriendView_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchAndFriendView()
    }
}
