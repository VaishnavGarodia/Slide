//
//  SettingsView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import FirebaseAuth
import SwiftUI
import UIKit

struct SettingsView: View {
    @State private var clicks = [false, false, false, false, false, false, false]
    @Binding var selectedColorScheme: String
    let user = Auth.auth().currentUser
    @State private var updatedUsername: String = ""
    @State private var isShowingTutorial = false
    @StateObject var notificationPermission = NotificationPermission()
    @State private var isDeleteErrorVisible = false
    @State private var deleteErrorMessage = ""
    
    var body: some View {
        List {
            // Username
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 0)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Username")
                                .foregroundColor(.primary)
                            Text(user?.displayName ?? "SimUser")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[0] ? 90 : 0))
                    }
                }
                
                if clicks[0] {
                    updateUsernameView(updatedUsername: $updatedUsername, clicked: $clicks[0])
                }
            }
            
            // Email
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 1)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Email")
                                .foregroundColor(.primary)
                            Text(user?.email ?? "SimUser@stanford.edu")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if !(user?.isEmailVerified ?? false) {
                            Button(action: {
                                // Add logic to resend email verification
                                Auth.auth().currentUser?.sendEmailVerification { error in
                                    if let error = error {
                                        print("Error sending verification email: \(error)")
                                    } else {
                                        print("Verification email sent.")
                                    }
                                }
                            }) {
                                Text("Resend")
                                    .foregroundColor(.red)
                            }
                        }
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[1] ? 90 : 0))
                    }
                }
                
                if clicks[1] {}
            }
            
            // Phone #
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 2)
                    }
                } label: {
                    HStack {
                        VStack {
                            Text("Phone Number")
                                .foregroundColor(.primary)
                            if !(user?.phoneNumber ?? "").isEmpty {
                                Text(user?.phoneNumber ?? "")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if (user?.phoneNumber ?? "").isEmpty {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                        }
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[2] ? 90 : 0))
                    }
                }
                if clicks[2] {
                    if (user?.phoneNumber ?? "").isEmpty {
                        PhoneNumberView()
                    } else {
                        Text("You've already set your phone number.")
                    }
                }
            }
            
            // Password
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 3)
                    }
                } label: {
                    HStack {
                        Text("Password")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[3] ? 90 : 0))
                    }
                }
                
                if clicks[3] {
                    PasswordView()
                }
            }
            
            // App Appearance
            //            Group {
            //                Button {
            //                    withAnimation {
            //                        toggleClicks(count: 4)
            //                    }
            //                } label: {
            //                    HStack {
            //                        Text("App Appearance")
            //                            .foregroundColor(.primary)
            //                        Spacer()
            //                        Image(systemName: "chevron.right")
            //                            .rotationEffect(.degrees(clicks[4] ? 90 : 0))
            //                    }
            //                }
            //
            //                if clicks[4] {
            //                    AppAppearanceView(selectedColorScheme: $selectedColorScheme)
            //                }
            //            }
            // Delete Account
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 6)
                    }
                } label: {
                    HStack {
                        Text("Delete Account")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[6] ? 90 : 0))
                    }
                }
                
                if clicks[6] {
                    Button("Confirm Delete") {
                        deleteAccount()
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $isDeleteErrorVisible) {
                        Alert(title: Text("Error"), message: Text(deleteErrorMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
            
            
            
            // Sign Out
            Group {
                Button {
                    withAnimation {
                        toggleClicks(count: 5)
                    }
                } label: {
                    HStack {
                        Text("Sign Out")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(clicks[5] ? 90 : 0))
                    }
                }
                
                if clicks[5] {
                    SignOutView()
                }
                Button {
                    isShowingTutorial.toggle()
                } label: {
                    Text("Tutorial")
                }
            }
        }
        
        .onChange(of: selectedColorScheme) { value in
            UserDefaults.standard.set(value, forKey: "colorSchemePreference")
        }
        .onAppear {
            selectedColorScheme = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "dark"
        }
        
        .fullScreenCover(isPresented: $isShowingTutorial) {
            TutorialView(isShowingTutorial: $isShowingTutorial)
        }
    }
    
    func toggleClicks(count: Int) {
        for index in 0 ..< clicks.count {
            if index != count {
                clicks[index] = false
            }
        }
        clicks[count].toggle()
    }
    
    func deleteAccount() {
        guard let currentUserID = user?.uid else {
            return
        }
        
        // Events
        deleteEvents(for: currentUserID)
        
        // Posts
        deletePosts(for: currentUserID)
        
        // TODO: AS THE THIRD TODO REITERATES, deleteFriendDocuments MUST BE COMPLETED BEFORE deleteUserDocument Starts
        // Friendships and outgoings/incomings
        deleteFriendDocuments(for: currentUserID)
        
        // TODO: Messages (sent and received?)
        
        
        // User and Username docs
        // TODO: deleteUsernameDocument has to COMPLETE before deleteUserDocument STARTS
        deleteUsernameDocument(for: currentUserID)
        // TODO: U basically just need this function to not run until everything above has run
        deleteUserDocument(for: currentUserID)
        
        //Firebase Auth
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print("Error deleting user: \(error)")
                deleteErrorMessage = error.localizedDescription
                isDeleteErrorVisible.toggle()
            } else {
                print("User account deleted successfully.")
                // Add any additional logic if you wish to navigate the user away, etc.
            }
        }
    }
    
    func deletePosts(for userID: String) {
        let postsCollectionRef = db.collection("Posts")

        var query = postsCollectionRef.whereField("User", isEqualTo: userID)

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching highlights: \(error.localizedDescription)")
                return
            }

            for document in snapshot?.documents ?? [] {
                let postID = document.documentID
                let postReference = db.collection("Posts").document(postID)
                postReference.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully deleted!")
                    }
                }
            }
        }
    }
    func deleteEvents(for userID: String) {
        let eventsCollectionRef = db.collection("Events")

        var query = eventsCollectionRef.whereField("User", isEqualTo: userID)

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching highlights: \(error.localizedDescription)")
                return
            }

            for document in snapshot?.documents ?? [] {
                let eventID = document.documentID
                let eventReference = db.collection("Events").document(eventID)
                eventReference.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully deleted!")
                    }
                }
            }
        }
    }
    func deleteFriendDocuments(for userID: String) {
        let userDocument = db.collection("User").document(userID)
        userDocument.getDocument { document, _ in
            if let document = document, document.exists {
                let incomingList = document.data()?["Incoming"] as? [String] ?? []
                let outgoingList = document.data()?["Outgoing"] as? [String] ?? []
                let friendList = document.data()?["Friends"] as? [String] ?? []
                for incoming in incomingList {
                    let incomingDocument = db.collection("User").document(incoming)
                    incomingDocument.getDocument { incomingDoc, _ in
                        if let incomingDoc = incomingDoc, incomingDoc.exists {
                            var incomingList = incomingDoc.data()?["Incoming"] as? [String] ?? []
                            incomingList.removeAll { $0 == userID }
                            incomingDocument.updateData(["Incoming": incomingList]) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document successfully updated with new score.")
                                }
                            }
                        }
                    }
                }
                for outgoing in outgoingList {
                    let outgoingDocument = db.collection("User").document(outgoing)
                    outgoingDocument.getDocument { outgoingDoc, _ in
                        if let outgoingDoc = outgoingDoc, outgoingDoc.exists {
                            var outgoingList = outgoingDoc.data()?["Outgoing"] as? [String] ?? []
                            outgoingList.removeAll { $0 == userID }
                            outgoingDocument.updateData(["Outgoing": outgoingList]) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document successfully updated with new score.")
                                }
                            }
                        }
                    }
                }
                for friend in friendList {
                    let friendDocument = db.collection("User").document(friend)
                    friendDocument.getDocument { friendDoc, _ in
                        if let friendDoc = friendDoc, friendDoc.exists {
                            var friendList = friendDoc.data()?["Friends"] as? [String] ?? []
                            friendList.removeAll { $0 == userID }
                            friendDocument.updateData(["Friends": friendList]) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document successfully updated with new score.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func deleteUsernameDocument(for userID: String) {
        let userDocument = db.collection("User").document(userID)
        userDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                // Document data exists, so you can access fields
                if let username = document.data()?["Username"] as? String {
                    let usernameDocumentRef = db.collection("Usernames").document(username)
                    usernameDocumentRef.delete { error in
                        if let error = error {
                            print("Error deleting document: \(error.localizedDescription)")
                        } else {
                            print("Document successfully deleted!")
                        }
                    }
                } else {
                    print("Field doesn't exist or is not a string.")
                }
            } else {
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    func deleteUserDocument(for userID: String) {
        let userDocument = db.collection("User").document(userID)
        userDocument.delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                print("Document successfully deleted!")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(selectedColorScheme: .constant("dark"))
    }
}
