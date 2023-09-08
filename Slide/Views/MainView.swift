//  MainView.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import AVFoundation
import FirebaseAuth
import SwiftUI

struct MainView: View {
    @State private var selectedColorScheme: String = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "dark"

    /* The selection variable here defines which tab on the tab view the app initially starts on (the map) */
    @State private var bubble = false
    @State private var chat = false
    @State private var messageDetails = ("", "")
    @State private var newMessage: RecentMessage? = nil
    @State private var selection = 2
    @State private var isPresentingPostCreationView = false
    @State private var source: UIImagePickerController.SourceType = .camera
    @StateObject private var vm = MainMessagesViewModel()
    @StateObject private var highlights = HighlightObject()
    var user = Auth.auth().currentUser

    var body: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selection) {
                    Highlights(source: $source, highlights: highlights, isPresentingPostCreationView: $isPresentingPostCreationView)
                        .tag(0)

                    MessagesTab(vm: vm)
                        .onAppear {
                            bubble = false
                        }
                        .tag(1)

                    MapPage()
                        .tag(2)

                    ProfileView()
                        .tag(3)

                    NavigationView {
                        SettingsView(selectedColorScheme: $selectedColorScheme)
                            .navigationTitle("Settings")
                    }
                    .tag(4)
                    .navigationViewStyle(.stack)
                }
                .onAppear {
                    vm.snapshotChangedHandler = { message in
                        showBubble(message)
                    }
                    initiateApp { completion in
                        
                    }
                }

                HStack {
                    if selection == 0 {
                        Menu {
                            Button {
                                withAnimation {
                                    source = .camera
                                    isPresentingPostCreationView = true
                                }
                            } label: {
                                Label("Post with Camera", systemImage: "camera")
                            }
                            Button {
                                withAnimation {
                                    source = .photoLibrary
                                    isPresentingPostCreationView = true
                                }
                            } label: {
                                Label("Post from Library", systemImage: "photo")
                            }
                        } label: {
                            Image(systemName: "plus.app")
                                .foregroundColor(.primary)
                                .imageScale(.large)
                                .padding(7.5)
                                .background(Color.accentColor.clipShape(Circle()))
                                .padding()
                        }
                    } else {
                        Image(systemName: "light.ribbon")
                            .tabBarItem(index: 0, selection: $selection)
                    }

                    Image(systemName: "person.2")
                        .tabBarItem(index: 1, selection: $selection)

                    Image(systemName: "map")
                        .tabBarItem(index: 2, selection: $selection)

                    Image(systemName: "person.circle")
                        .tabBarItem(index: 3, selection: $selection)

                    Image(systemName: "gear")
                        .tabBarItem(index: 4, selection: $selection)
                }
                .frame(width: UIScreen.main.bounds.width, height: 55)
                .background(selectedColorScheme == "dark" ? Color.black : Color.white)
                .ignoresSafeArea()
                .fullScreenCover(isPresented: $chat) {
                    ChatView(chatUser: ChatUser(uid: newMessage!.fromId == user!.uid ? newMessage!.toId : newMessage!.fromId, profileImageUrl: ""))
                }
            }
            if bubble {
                VStack {
                    HStack {
                        UserProfilePictures(photoURL: messageDetails.1, dimension: 40)
                        VStack(alignment: .leading) {
                            Text(messageDetails.0)
                                .fontWeight(.semibold)
                            Text(newMessage?.text ?? "")
                        }
                        Spacer()
                    }
                    .foregroundColor(Color.white)
                    .padding()
                    .background(Color.darkGray)
                    .cornerRadius(10)
                    Spacer()
                }
                .padding()
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        bubble = false
                        chat = true
                        selection = 1
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            bubble = false
                        }
                    }
                }
            }
        }
    }

    func showBubble(_ message: RecentMessage) {
        newMessage = message
        fetchUsernameAndPhotoURL(for: newMessage!.fromId == user!.uid ? newMessage!.toId : newMessage!.fromId) { name, photo in
            messageDetails = (name!, photo!)
            withAnimation {
                if selection != 1 {
                    // AudioServicesPlaySystemSound(1003)
                    bubble.toggle()
                }
            }
        }
    }

    func initiateApp(completion: @escaping (Bool) -> Void) {
        fetchHighlights()
        fetchGalleries()
        completion(true)
    }

    func fetchHighlights() {
        let postsCollectionRef = db.collection("Posts")

        let twoDaysAgo = Calendar.current.date(byAdding: .hour, value: -48, to: Date())!

        postsCollectionRef.whereField("PostTime", isGreaterThan: twoDaysAgo).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching highlights: \(error.localizedDescription)")
                return
            }

            var newHighlights: [HighlightInfo] = []
            let dispatchGroup = DispatchGroup()

            for document in snapshot?.documents ?? [] {
                if let caption = document.data()["ImageCaption"] as? String,
                   let userDocumentID = document.data()["User"] as? String,
                   let imagePath = document.data()["PostImage"] as? String
                {
                    guard let currentUserID = user?.uid else {
                        return
                    }
                    let userDocumentRef = db.collection("Users").document(currentUserID)

                    // Step 1: Access the User document using the given document ID
                    userDocumentRef.getDocument(completion: { d2, _ in
                        if let d2 = d2, d2.exists {
                            let docID = document.documentID
                            var friendsArray: [String] = []
                            if let tempFriendsArray = d2.data()?["Friends"] as? [String] {
                                friendsArray = tempFriendsArray
                            }
                            var likedUsersArray: [String] = []
                            if let tempLikedUsersArray = d2.data()?["Liked Users"] as? [String] {
                                likedUsersArray = tempLikedUsersArray
                            }
                            if friendsArray.contains(userDocumentID), userDocumentID != currentUserID {
                                dispatchGroup.enter()

                                fetchUsernameAndPhotoURL(for: userDocumentID) { username, photoURL in
                                    if let username = username, let photoURL = photoURL {
                                        let highlight = HighlightInfo(
                                            uid: currentUserID, postID: docID, imageName: imagePath, profileImageName: photoURL, username: username, highlightTitle: caption, likedUsers: likedUsersArray
                                        )
                                        newHighlights.append(highlight)
                                        dispatchGroup.leave()
                                    }
                                }
                            }
                        }
                        dispatchGroup.notify(queue: .main) {
                            highlights.highlights = newHighlights
                        }
                    })
                }
            }
        }
    }

    func fetchGalleries() {
        getEventGalleries { eventGalleries, error in
            if let error = error {
                print("Error fetching event galleries: \(error.localizedDescription)")
                return
            }

            if let temp = eventGalleries {
                highlights.galleries = temp
                return
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
