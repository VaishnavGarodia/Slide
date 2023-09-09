import Firebase
import FirebaseFirestore
import SwiftUI

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
            GeometryReader { geometry in
                ScrollView {
                    if highlights.galleries.isEmpty && highlights.highlights.isEmpty {
                        NoHighlightsView()
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    } else {
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
                }
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
            // fetchHighlights()
            // fetchGalleries()
        }
        .onAppear {
            // fetchHighlights()
            // fetchGalleries()
        }
    }

    struct NoHighlightsView: View {
        var body: some View {
            VStack {
                Text("Welcome to Highlights!")
                    .font(.title)
                    .bold()
                Text("There's nothing here now, but come back once you've attended some events!")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        Highlights(source: .constant(.camera), highlights: HighlightObject(), isPresentingPostCreationView: .constant(false))
    }
}
