import Firebase
import FirebaseFirestore
import SwiftUI

/* Tom Holland test data: [HighlightInfo(imageName: "https://m.media-amazon.com/images/M/MV5BNzZiNTEyNTItYjNhMS00YjI2LWIwMWQtZmYwYTRlNjMyZTJjXkEyXkFqcGdeQXVyMTExNzQzMDE0._V1_FMjpg_UX1000_.jpg", profileImageName: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", username: "User 1", highlightTitle: "Highlight 1"), HighlightInfo(imageName: "https://www.advocate.com/media-library/tom-holland.jpg?id=34342705&width=980&quality=85", profileImageName: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", username: "User 1", highlightTitle: "Highlight 1")] */

struct Highlights: View {
    @State private var highlights: [HighlightInfo] = [HighlightInfo(imageName: "https://m.media-amazon.com/images/M/MV5BNzZiNTEyNTItYjNhMS00YjI2LWIwMWQtZmYwYTRlNjMyZTJjXkEyXkFqcGdeQXVyMTExNzQzMDE0._V1_FMjpg_UX1000_.jpg", profileImageName: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", username: "User 1", highlightTitle: "Highlight 1"), HighlightInfo(imageName: "https://www.advocate.com/media-library/tom-holland.jpg?id=34342705&width=980&quality=85", profileImageName: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", username: "User 1", highlightTitle: "Highlight 1")]
    @State private var isPresentingPostCreationView = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(highlights) { highlight in
                        HighlightCard(highlight: highlight)
                            .cornerRadius(25)
                            .padding()
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
        let postsCollectionRef = db.collection("Posts")

        postsCollectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching highlights: \(error.localizedDescription)")
                return
            }

            var newHighlights: [HighlightInfo] = []
            let dispatchGroup = DispatchGroup() // Create a DispatchGroup

            for document in snapshot?.documents ?? [] {
                if let caption = document.data()["ImageCaption"] as? String,
                   let userDocumentID = document.data()["User"] as? String,
                   let imagePath = document.data()["PostImage"] as? String
                {
                    dispatchGroup.enter() // Enter the DispatchGroup before starting an asynchronous task

                    // Fetch username from the "Users" database using the userDocumentID
                    fetchUsername(for: userDocumentID) { username, photoURL in
                        if let username = username, let photoURL = photoURL {
                            let highlight = HighlightInfo(
                                imageName: imagePath, profileImageName: photoURL, username: username, highlightTitle: caption
                            )
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
}

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        Highlights()
    }
}
