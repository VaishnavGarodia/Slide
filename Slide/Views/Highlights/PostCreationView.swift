import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import UIKit

struct PostCreationView: View {
    @State private var showImagePicker = false
    @State private var image: UIImage?
    @State private var isImageSelected = false
    @State private var isSubmitTapped = false
    @State private var imageCaption = ""
    @State private var selectedSourceType: UIImagePickerController.SourceType = .camera
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            if let image = image {
                Image(uiImage: image)
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
                
            } else {
                VStack(spacing: 20) {
                    Button(action: {
                        selectedSourceType = .camera // Set the source type to camera
                        showImagePicker = true
                    }) {
                        Text("Take Picture")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        selectedSourceType = .photoLibrary // Set the source type to photo library
                        showImagePicker = true
                    }) {
                        Text("Choose from Library")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerPost(isImageSelected: $isImageSelected, image: $image, sourceType: selectedSourceType)
                        .onDisappear {
                            if !isImageSelected && !isSubmitTapped {
                                showImagePicker = false
                            }
                        }
                }
            }
        }
        .onChange(of: isSubmitTapped) { _ in
            // Dismiss the view when the image is selected
            if isSubmitTapped {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
                       
    func savePostToFirestore() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }

        let postsCollection = db.collection("Posts")

        let postTime = Date()

        let postDocument: [String: Any] = [
            "User": currentUser.uid,
            "ImageCaption": imageCaption,
            "Likes": 0,
            "PostTime": postTime
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
        }
        
        // Set isSubmitTapped to true in the same frame
        // where we set it to true in the Button action
        DispatchQueue.main.async {
            isSubmitTapped = true
        }
    }

    func uploadImageToFirebaseStorage(image: UIImage, documentID: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
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
}

struct ImagePickerPost: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isImageSelected: Bool
    @Binding var image: UIImage?
    
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerPost
        
        init(_ parent: ImagePickerPost) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.isImageSelected = true
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
