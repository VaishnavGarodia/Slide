import SwiftUI
import Firebase
import FirebaseFirestore

struct Highlights: View {
    @State private var highlights: [HighlightInfo] = [
        HighlightInfo(imageName: "Highlight1", profileImageName: "ProfilePic2", username: "Zendaya", highlightTitle: "Spider-Man Photoshoot")
    ]
    @State private var isPresentingPostCreationView = false
    
    var body: some View {
        VStack {
            Button(action: {
                isPresentingPostCreationView = true
            }) {
                Image(systemName: "person")
                    .padding()
                    .imageScale(.large)
            }
            .foregroundColor(.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(highlights) { highlight in
                        HighlightCard(highlight: highlight)
                    }
                }
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
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 100 {
                    isPresentingPostCreationView = false
                }
            }
        )
        .refreshable {
            fetchHighlights()
        }
        .onAppear {
            fetchHighlights()
        }
    }

    func fetchHighlights() {
        let db = Firestore.firestore()
        let postsCollectionRef = db.collection("Posts")

        postsCollectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching highlights: \(error.localizedDescription)")
                return
            }

            var newHighlights: [HighlightInfo] = []
            let dispatchGroup = DispatchGroup() // Create a DispatchGroup

            for document in snapshot?.documents ?? [] {
                if let caption = document.data()["ImageCaption"] as? String,
                   let userDocumentID = document.data()["User"] as? String,
                   let imagePath = document.data()["PostImage"] as? String {

                    dispatchGroup.enter() // Enter the DispatchGroup before starting an asynchronous task

                    // Fetch username from the "Users" database using the userDocumentID
                    fetchUsername(for: userDocumentID) { username in
                        if let username = username {
                            let highlight = HighlightInfo(
                                imageName: imagePath, profileImageName: "ProfilePic2", username: username, highlightTitle: caption)
                            newHighlights.append(highlight)

                            dispatchGroup.leave() // Leave the DispatchGroup when the task is complete
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                // This block is called when all the tasks inside the DispatchGroup are completed
                self.highlights = newHighlights
            }
        }
    }

    func fetchUsername(for documentID: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let userDocumentRef = db.collection("Users").document(documentID)

        userDocumentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let username = document.data()?["Username"] as? String {
                    completion(username)
                } else {
                    completion(nil)
                }
            } else {
                print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
}

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        Highlights()
    }
}
