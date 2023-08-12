import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import SwiftUI
import UIKit

// TODO: Extract this into a new file please
struct PostCreationView: View {
    @State var isPhotoLibraryAuthorized = false
    @State private var showImagePickerCamera = false
    @State private var showImagePickerLibrary = false
    @State private var image: UIImage?
    @State private var isSubmitTapped = false
    @State private var imageCaption = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isSubmitEnabled = false
    @State private var selectedEvent: EventDisplay?
    @State private var eligibleEvents: [EventDisplay] = []
    @State private var hasSelected: Bool = false
    @State private var hasSelectedImage: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            
            Picker("Select an Event", selection: $selectedEvent) {
                Text("Select an Event")
                    .tag(nil as EventDisplay?) // Tag for the default value
                ForEach(eligibleEvents, id: \.id) { event in
                    Text(event.name).tag(event as EventDisplay?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedEvent, perform: { newValue in
                if let selectedEvent = newValue {
                    // Handle the selected event
                    print("Selected event: \(selectedEvent.name)")
                    hasSelected = true // Update the hasSelected state
                } else {
                    hasSelected = false // Update the hasSelected state
                }
            })

            Image(uiImage: image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding()
            TextField("Image Caption", text: $imageCaption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            Button(action: {
                isSubmitTapped = true
                savePostToFirestore()
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .disabled(!hasSelected) // Disable the submit button when "Select Event" is selected
            .opacity(hasSelected ? 1.0 : 0.5) // Apply opacity to indicate disabled state
            
            if hasSelected {
                VStack(spacing: 20) {
                    Text("Take Picture")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            showImagePickerCamera = true
                        }
                    Text("Choose from Library")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            showImagePickerLibrary = true
                        }
                }
                .padding(.horizontal, 20)
            }

        }
        .onChange(of: isSubmitTapped) { _ in
            // Dismiss the view when the image is selected
            if isSubmitTapped {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            checkPhotoLibraryPermission()
            if !isPhotoLibraryAuthorized {
                requestPhotoLibraryPermission()
            }
            // Fetch eligible events when the view appears
            getEligibleEvents { events, error in
                if let events = events {
                    eligibleEvents = events
                } else {
                    // Handle the error here, if needed
                    print("Error fetching eligible events: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        .sheet(isPresented: $showImagePickerCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $image, wasSelected: hasSelectedImage)
        }
        .sheet(isPresented: $showImagePickerLibrary) {
            PhotoLibraryLimitedPicker(isImageSelected: $hasSelectedImage, selectedImage: $image)
//            ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
                .onAppear {
                    // Reset UITabBar appearance properties to default values
                    UITabBar.appearance().unselectedItemTintColor = nil
                    UITabBar.appearance().isTranslucent = true
                    UITabBar.appearance().backgroundColor = nil
                }
                .onDisappear {
                    UITabBar.appearance().unselectedItemTintColor = .white
                    UITabBar.appearance().isTranslucent = false
                    UITabBar.appearance().backgroundColor = .black
                }
        }
    }

    func fetchEligibleEvents() {
        getEligibleEvents { events, error in
            if let error = error {
                // Handle error if needed
                print("Error fetching eligible events: \(error.localizedDescription)")
            } else if let events = events {
                // Update the eligibleEvents property
                eligibleEvents = events
            }
        }
    }

    func savePostToFirestore() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }
        guard let selectedEvent = selectedEvent else {
            print("No event selected")
            return
        }
        let postsCollection = db.collection("Posts")
        let postTime = Date()
        let postDocument: [String: Any] = [
            "User": currentUser.uid,
            "ImageCaption": imageCaption,
            "Likes": 0,
            "PostTime": postTime,
            "Event": selectedEvent.id // Save the selected event ID along with other post details
        ]
        let newPostDocument = postsCollection.document()
        // Save the post document to Firestore
        newPostDocument.setData(postDocument) { error in
            if let error = error {
                print("Error saving post to Firestore: \(error.localizedDescription)")
            } else {
                print("Post saved to Firestore successfully")
                // Upload the image to Firebase Storage
                uploadImageToFirebaseStorage(image: image ?? UIImage(), documentID: newPostDocument.documentID)
            }
            // Also have to add the post id to the events Associated Posts field.
            let postID = newPostDocument.documentID
            let eventID = selectedEvent.id
            let eventRef = db.collection("Events").document(eventID)
            eventRef.getDocument { document, _ in
                if let document = document, document.exists {
                    var associatedHighlights = document.data()?["Associated Highlights"] as? [String] ?? []
                    associatedHighlights.append(postID)
                    eventRef.updateData(["Associated Highlights": associatedHighlights])
                } else {
                    print("Event document not found!")
                }
            }
        }

        // Set isSubmitTapped to true in the same frame
        // where we set it to true in the Button action
        DispatchQueue.main.async {
            isSubmitTapped = true
        }
    }

    

    func uploadImageToFirebaseStorage(image: UIImage, documentID: String) {
        guard let imageData = compressImageToTargetSize(image, targetSizeInKB: 100) else {
            print("Failed to compress image.")
            return
        }
        let storageRef = Storage.storage().reference().child("PostImages/\(documentID).jpg")
        let uploadTask = storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else if let downloadURL = url {
                        // Update the post document with the image download URL
                        let db = Firestore.firestore()
                        let postDocumentRef = db.collection("Posts").document(documentID)
                        postDocumentRef.updateData(["PostImage": downloadURL.absoluteString]) { error in
                            if let error = error {
                                print("Error updating post document: \(error.localizedDescription)")
                            } else {
                                print("Post document updated successfully with image URL")
                            }
                        }
                    }
                }
            }
        }
        uploadTask.resume()
    }

    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        isPhotoLibraryAuthorized = (status == .authorized)
    }

    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                isPhotoLibraryAuthorized = (status == .authorized)
            }
        }
    }
}

func compressImageToTargetSize(_ image: UIImage, targetSizeInKB: Int) -> Data? {
    let targetWidth: CGFloat = 1024 // Choose the desired width here
    let targetHeight = targetWidth * (image.size.height / image.size.width)
    let size = CGSize(width: targetWidth, height: targetHeight)

    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(origin: .zero, size: size))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    // Check if the scaled image data is already below the target size
    if let scaledImageData = scaledImage?.jpegData(compressionQuality: 1.0) {
        let scaledSizeInKB = scaledImageData.count / 1024
        if scaledSizeInKB <= targetSizeInKB {
            return scaledImageData
        }
    }
    var compressionQuality: CGFloat = 1.0
    var imageData: Data?

    // Binary search to find the optimal compression quality
    var minQuality: CGFloat = 0.0
    var maxQuality: CGFloat = 1.0
    while minQuality <= maxQuality {
        compressionQuality = (minQuality + maxQuality) / 2.0
        if let compressedData = scaledImage?.jpegData(compressionQuality: compressionQuality) ?? image.jpegData(compressionQuality: compressionQuality) {
            let currentSizeInKB = compressedData.count / 1024
            if currentSizeInKB > targetSizeInKB {
                maxQuality = compressionQuality - 0.0001
            } else {
                imageData = compressedData
                minQuality = compressionQuality + 0.0001
            }
        } else {
            break
        }
    }

    return imageData
}
