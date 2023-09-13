//
//  HighlightObject.swift
//  Slide
//
//  Created by Ethan Harianto on 9/9/23.
//

import Firebase
import Foundation

class HighlightObject: ObservableObject {
    @Published var highlights: [HighlightInfo] = []
    @Published var lastSnapshot: DocumentSnapshot?
    @Published var galleries: [Event] = []
    @Published var posts: [CombinedPost] = []

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
                   let imagePath = document.data()["PostImage"] as? String,
                   let postTime = (document.data()["Post Time"] as? Timestamp)?.dateValue()
                {
                    guard let currentUserID = Auth.auth().currentUser?.uid else {
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
                                            uid: currentUserID, postID: docID, imageName: imagePath, profileImageName: photoURL, username: username, highlightTitle: caption, likedUsers: likedUsersArray, postTime: postTime
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
        getEventGalleries { eventGalleries, error in
            if let error = error {
                print("Error fetching event galleries: \(error.localizedDescription)")
                return
            }

            if let temp = eventGalleries {
                self.galleries = temp
                return
            }
        }
    }

    func combineAndSortPosts() {
        var combinedPosts: [CombinedPost] = []

        for highlight in highlights {
            combinedPosts.append(CombinedPost(timestamp: highlight.postTime, content: .highlight(highlight)))
        }

        for gallery in galleries {
            combinedPosts.append(CombinedPost(timestamp: gallery.start, content: .gallery(gallery)))
        }

        combinedPosts.sort { $0.timestamp > $1.timestamp }

        posts = combinedPosts
    }

    struct CombinedPost: Identifiable {
        let id = UUID()
        let timestamp: Date
        let content: PostContent
    }

    enum PostContent {
        case highlight(HighlightInfo)
        case gallery(Event)
    }

    func fetch() {
        fetchHighlights()
        fetchGalleries()
        combineAndSortPosts()
    }
}
