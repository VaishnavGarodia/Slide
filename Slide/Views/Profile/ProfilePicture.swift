import SwiftUI
import UIKit
import FirebaseStorage
import Firebase
import FirebaseFirestore

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = .photoLibrary
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProfilePicture: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var profilePictureURL: URL?
    
    private let profilePictureKey = "ProfilePictureURL"
    
    var body: some View {
        Button(action: {
            isShowingImagePicker = true
        }) {
            Group {
                if let image = selectedImage {
                    ZStack {
                        Color.accentColor
                            .frame(width: 130, height: 130)
                            .clipShape(Circle())
                        Color.black
                            .frame(width: 125, height: 125)
                            .clipShape(Circle())

                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                    }
                } else if let url = profilePictureURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
                .onDisappear {
                    uploadProfilePicture()
                }
        }
        .onAppear {
            loadProfilePictureURL()
        }
    }
    
    func uploadProfilePicture() {
        guard let image = selectedImage else { return }
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profilePictures/\(imageName).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image to storage: \(error.localizedDescription)")
                } else {
                    storageRef.downloadURL { url, error in
                        if let downloadURL = url {
                            profilePictureURL = downloadURL
                            saveProfilePictureURL()
                            updateProfilePictureURL()
                        } else if let error = error {
                            print("Error retrieving image download URL: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func updateProfilePictureURL() {
        guard let currentUser = Auth.auth().currentUser,
              let profilePictureURL = profilePictureURL else { return }
        
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userRef.updateData(["profilePictureURL": profilePictureURL.absoluteString]) { error in
            if let error = error {
                print("Error updating user profile picture URL: \(error.localizedDescription)")
            }
        }
    }
    
    func saveProfilePictureURL() {
        guard let profilePictureURL = profilePictureURL else { return }
        
        let defaults = UserDefaults.standard
        defaults.set(profilePictureURL.absoluteString, forKey: profilePictureKey)
    }
    
    func loadProfilePictureURL() {
        let defaults = UserDefaults.standard
        guard let urlString = defaults.string(forKey: profilePictureKey),
              let url = URL(string: urlString) else { return }
        
        profilePictureURL = url
    }
}
