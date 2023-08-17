import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine

struct BigEventView: View {
    var eventID: String
    
    @State private var posts: [HighlightInfo] = [] // Holds the list of associated posts
    @State private var highlight: HighlightInfo? // Holds the selected highlight
    @State private var userData: UserData?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(posts) { post in
                    Button(action: {
                        highlight = post // Set the selected highlight
                    }) {
                        HighlightImageMini(imageURL: URL(string: post.imageName)!)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadAssociatedPosts()
            print(posts)
        }
        .sheet(item: $highlight) { highlight in
            // Present the highlight card using the sheet modifier
            HighlightCard(highlight: highlight, selectedUser: $userData, profileView: .constant(false))
        }
    }
    
    private func loadAssociatedPosts() {
        let eventDocumentRef = Firestore.firestore().collection("Events").document(eventID)
        let group = DispatchGroup() // Create a DispatchGroup
        
        group.enter() // Notify the group that a task has started
        
        eventDocumentRef.getDocument { document, error in
            if let document = document, document.exists {
                if let associatedHighlights = document.data()?["Associated Highlights"] as? [String] {
                    for highlightID in associatedHighlights {
                        group.enter() // Notify the group that another task has started
                        let highlightDocumentRef = Firestore.firestore().collection("Posts").document(highlightID)
                        highlightDocumentRef.getDocument { document2, error2 in
                            if let document2 = document2, document2.exists {
                                let userLikes = document2.data()?["Liked Users"] as? [String] ?? []
                                if let postID = document2.documentID as? String,
                                   let uid = document2.data()?["User"] as? String,
                                   let imageName = document2.data()?["PostImage"] as? String,
                                   let highlightTitle = document2.data()?["ImageCaption"] as? String {
                                    // Fetch the user document using the extracted uid
                                    group.enter() // Enter the DispatchGroup before starting each fetchUserDetails call
                                    fetchUserDetails(userID: uid) { userDetails in
                                        let userDetails = userDetails
                                        userData = userDetails
                                        group.leave() // Leave the DispatchGroup after the fetchUserDetails call is completed
                                    }
                                    posts.append(HighlightInfo(uid: uid, postID: postID, imageName: imageName, profileImageName: userData?.photoURL ?? imageName, username: userData?.username ?? uid, highlightTitle: highlightTitle, likedUsers: userLikes))

                                }
                            }
                            group.leave() // Notify the group that the highlight task is done
                        }
                    }
                }
            }
            group.leave() // Notify the group that the event task is done
        }
        
        group.notify(queue: .main) {
            // This closure will be executed once all tasks are done
            // You can do any final updates here
            // For example, you could reload the view or perform any other actions
            return
        }
    }
}
