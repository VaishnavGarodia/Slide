import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import UIKit
import PhotosUI

struct ProfilePicture: View {
    @State private var isImageSelected = false
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var profilePictureURL: URL?
    @State private var isPhotoLibraryAuthorized = false
    
    private let profilePictureKey = "ProfilePictureURL"
    
    var body: some View {
        Button(action: {
            isShowingImagePicker = true
        }) {
            Group {
                if let image = selectedImage {
                    ZStack {
                        Color.accentColor
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        Color.black
                            .frame(width: 115, height: 115)
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
            ImagePicker(isImageSelected: $isImageSelected, image: $selectedImage, sourceType: .photoLibrary)
                .onAppear {
                    checkPhotoLibraryPermission()
                    if isPhotoLibraryAuthorized {
                    } else {
                        requestPhotoLibraryPermission()
                    }
                }
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
        let storageRef = storageRef.child("profilePictures/\(imageName).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { _, error in
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
        
        let userRef = Firestore.firestore().collection("Users").document(currentUser.uid)
        userRef.updateData(["_rofilePictureURL": profilePictureURL.absoluteString]) { error in
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
