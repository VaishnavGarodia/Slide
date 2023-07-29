// UserSearchAndFriendView.swift
// Slide
// Created by Thomas on 6/29/23.

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct userData: Codable {
    let userID: String
    let username: String
    let password: String
    let email: String
    let photoURL: String
    let added: Bool
}

struct UserSearchAndFriendView: View {
    let user = Auth.auth().currentUser
    @State private var searchQuery = ""
    @State private var searchResults: [userData] = []
    @State private var selectedUser: userData? = nil
    @State private var showingConfirmationDialog = false
    @State private var showPendingFriendRequests = false
    @State private var pendingFriendRequests: [userData] = []
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchQuery, onEditingChanged: { _ in
                    searchUsers()
                })
                .onChange(of: searchQuery) { _ in
                    searchUsers()
                }
            }
            .checkMarkTextField()
            .bubbleStyle(color: .primary)
            .padding()

            if searchQuery.isEmpty {
                if !pendingFriendRequests.isEmpty && searchResults.isEmpty {
                    Section("New Friend Requests") {
                        List(pendingFriendRequests, id: \.userID) { user in
                            HStack {
                                UserProfilePictures(photoURL: user.photoURL, dimension: 30)
                                Text(user.username)
                                    .foregroundColor(.white)
                                Spacer()
                                if user.added {
                                    Button {
                                        selectedUser = user
                                    } label: {
                                        Text("Accepted")
                                            .padding(5)
                                            .foregroundColor(.gray)
                                            .background(.black)
                                            .cornerRadius(10)
                                            
                                    }
                                } else {
                                    Button {
                                        selectedUser = user
                                        showingConfirmationDialog = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus")
                                            Text("Accept")
                                        }
                                        .padding(5)
                                        .foregroundColor(.accentColor)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(.white, lineWidth: 1)
                                        )
                                    }
                                }
                                
                            }
                        }
                    }
                }
                else {
                    Spacer()
                }
            }

            if !searchResults.isEmpty {
                Section("Search Results") {
                    List(searchResults, id: \.userID) { user in
                        HStack {
                            UserProfilePictures(photoURL: user.photoURL, dimension: 30)
                            Text(user.username)
                                .foregroundColor(.white)

                            Spacer()
                            if user.added {
                                Button {
                                    selectedUser = user
                                } label: {
                                    Text("Added")
                                        .padding(5)
                                        .foregroundColor(.gray)
                                        .background(.black)
                                        .cornerRadius(10)
                                        
                                }
                            } else {
                                Button {
                                    selectedUser = user
                                    showingConfirmationDialog = true
                                } label: {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Add")
                                    }
                                    .padding(5)
                                    .foregroundColor(.accentColor)
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.white, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .alert(isPresented: $showingConfirmationDialog) {
                        Alert(
                            title: Text("Send Friend Request"),
                            message: Text("Do you want to send a friend request to \(selectedUser?.username ?? "")?"),
                            primaryButton: .default(Text("Send"), action: {
                                sendFriendRequest()
                                searchUsers()
                            }),
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
        .padding()
        .onAppear {
            fetchPendingFriendRequests()
        }
        .refreshable {
            searchResults.removeAll()
            fetchPendingFriendRequests()
        }
    }

    func searchUsersByUsername(username: String, completion: @escaping ([userData]) -> Void) {
        let query = db.collection("Users")
            .whereField("Username", isGreaterThanOrEqualTo: username)
            .whereField("Username", isLessThan: username + "z")
            .whereField("Username", isNotEqualTo: user?.displayName ?? "SimUser")
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error searching users: \(error.localizedDescription)")
                completion([])
                return
            }
            var users: [userData] = []
            for document in snapshot?.documents ?? [] {
                if let username = document.data()["Username"] as? String,
                   let password = document.data()["Password"] as? String,
                   let email = document.data()["Email"] as? String,
                   let photoURL = document.data()["ProfilePictureURL"] as? String,
                   let incoming = document.data()["Incoming"] as? [String],
                   let friends = document.data()["Friends"] as? [String]
                {
                    let added = incoming.contains(user?.uid ?? "SimUser")
                    let potential = userData(
                        userID: document.documentID,
                        username: username,
                        password: password,
                        email: email,
                        photoURL: photoURL,
                        added: added
                    )
                    if !friends.contains(user?.uid ?? "SimUser") {
                        users.append(potential)
                    }
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
        guard let currentUserID = user?.uid,
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
                    if !outgoingList.contains(selectedUserID) {
                        outgoingList.append(selectedUserID)
                    }
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
        guard let currentUserID = user?.uid else {
            return
        }
        let userDocumentRef = db.collection("Users").document(currentUserID)
        var pendingRequests: [userData] = []

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

    func fetchUserDetails(userID: String, completion: @escaping (userData?) -> Void) {
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
               let photoURL = document.data()?["ProfilePictureURL"] as? String,
               let email = document.data()?["Email"] as? String,
               let incoming = document.data()?["Incoming"] as? [String]
            {
                let added = incoming.contains(user?.uid ?? "SimUser")
                let userDetails = userData(userID: userID, username: username, password: password, email: email, photoURL: photoURL, added: added)
                completion(userDetails)
            }
            else {
                completion(nil) // Call completion with nil if document is missing required fields
            }
        }
    }

    func confirmFriendship(u1: String, u2: String) {
        if u1 == "" || u2 == "" {
            return
        }
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
                friendList.append(u1)
                u2DocRef.updateData(["Friends": friendList])
                u2DocRef.updateData(["Outgoing": outgoingList])
                u2DocRef.updateData(["Incoming": incomingList])
            }
            else {
                print("User document not found!")
            }
        }
    }
    
    func rejectFriendship(u1: String, u2: String) {
        if u1 == "" || u2 == "" {
            return
        }
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
