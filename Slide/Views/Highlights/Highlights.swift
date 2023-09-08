import Firebase
import FirebaseFirestore
import SwiftUI

/* Tom Holland test data: [HighlightInfo(imageName: "https://m.media-amazon.com/images/M/MV5BNzZiNTEyNTItYjNhMS00YjI2LWIwMWQtZmYwYTRlNjMyZTJjXkEyXkFqcGdeQXVyMTExNzQzMDE0._V1_FMjpg_UX1000_.jpg", profileImageName: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", username: "User 1", highlightTitle: "Highlight 1"), HighlightInfo(imageName: "https://www.advocate.com/media-library/tom-holland.jpg?id=34342705&width=980&quality=85", profileImageName: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", username: "User 1", highlightTitle: "Highlight 1")] */

struct Highlights: View {
    @Binding var source: UIImagePickerController.SourceType
    @ObservedObject var highlights: HighlightObject
    @Binding var isPresentingPostCreationView: Bool
    let user = Auth.auth().currentUser
    @State private var profileView = false
    @State private var eventView = false
    @State private var selectedUser: UserData? = nil
    @State private var selectedEvent: Event? = Event()

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 50) {
                    ForEach(highlights.galleries, id: \.name) { gallery in
                        EventGalleryCard(event: gallery, profileView: $profileView, selectedUser: $selectedUser, eventView: $eventView, selectedEvent: $selectedEvent)
                    }
                    ForEach(highlights.highlights) { highlight in
                        HighlightCard(highlight: highlight, selectedUser: $selectedUser, profileView: $profileView)
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
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
                PostCreationView(source: $source)
            }
        }
        .fullScreenCover(isPresented: $profileView) {
            UserProfileView(user: $selectedUser)
        }
        .fullScreenCover(isPresented: $eventView) {
            EventDetailsView(event: Binding($selectedEvent)!, eventView: $eventView, gallery: false)
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 100 {
                    isPresentingPostCreationView = false
                }
            }
        )
        .refreshable {
//            fetchHighlights()
//            fetchGalleries()
        }
        .onAppear {
//            fetchHighlights()
//            fetchGalleries()
        }
    }
}

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        Highlights(source: .constant(.camera), highlights: HighlightObject(), isPresentingPostCreationView: .constant(false))
    }
}
