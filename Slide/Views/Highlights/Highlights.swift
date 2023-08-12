import Firebase
import FirebaseFirestore
import SwiftUI

/* Tom Holland test data: [HighlightInfo(imageName: "https://m.media-amazon.com/images/M/MV5BNzZiNTEyNTItYjNhMS00YjI2LWIwMWQtZmYwYTRlNjMyZTJjXkEyXkFqcGdeQXVyMTExNzQzMDE0._V1_FMjpg_UX1000_.jpg", profileImageName: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", username: "User 1", highlightTitle: "Highlight 1"), HighlightInfo(imageName: "https://www.advocate.com/media-library/tom-holland.jpg?id=34342705&width=980&quality=85", profileImageName: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", username: "User 1", highlightTitle: "Highlight 1")] */

struct Highlights: View {
    @State private var galleries: [EventGalleryInfo] = []
    @State private var highlights: [HighlightInfo] = []
    @State private var isPresentingPostCreationView = false
    let user = Auth.auth().currentUser
    @State private var profileView = false
    @State private var selectedUser: UserData? = nil

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(galleries) { gallery in
                        EventGalleryCard(eventGalleryInfo: gallery, profileView: $profileView, selectedUser: $selectedUser)
                    }
                    ForEach(highlights) { highlight in
                        HighlightCard(highlight: highlight, selectedUser: $selectedUser, profileView: $profileView)
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)

            VStack(alignment: .center) {
                Spacer()
                Button(action: {
                    isPresentingPostCreationView = true
                }) {
                    Image(systemName: "plus.app")
                        .foregroundColor(.white)
                        .padding()
                        .imageScale(.large)
                }
                .background(Circle().foregroundColor(.accentColor))
                .padding()
            }
        }
        .fullScreenCover(isPresented: $isPresentingPostCreationView) {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresentingPostCreationView = false
                    }) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                PostCreationView()
            }
        }
        .fullScreenCover(isPresented: $profileView) {
            UserProfileView(user: $selectedUser)
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 100 {
                    isPresentingPostCreationView = false
                }
            }
        )
        .refreshable {
            fetchHighlights()
            fetchGalleries()
        }
        .onAppear {
            fetchHighlights()
            fetchGalleries()
        }
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
                    print("Found Something")
                    
                    guard let currentUserID = user?.uid else {
                        return
                    }
                    let userDocumentRef = db.collection("Users").document(currentUserID)

                    // Step 1: Access the User document using the given document ID
                    userDocumentRef.getDocument(completion: {d2, e2 in
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
                            if friendsArray.contains(userDocumentID) {
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
                            self.highlights = newHighlights
                        }
                    })
                }
            }

        }
    }
    
    func fetchGalleries() {
        getEventGalleryInfos { eventGalleries, error in
            if let error = error {
                print("Error fetching event galleries: \(error.localizedDescription)")
                return
            }

            if let temp = eventGalleries {
                galleries = temp
                return
            }
        }
    }
}

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        Highlights()
    }
}
