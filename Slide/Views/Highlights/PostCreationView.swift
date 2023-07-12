//
//  PostCreationView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import SwiftUI

struct PostCreationView: View {
    @State private var showImagePicker = false
    @State private var image: Image? = nil
    @State private var isImageSelected = false // Track if an image is selected
    @State private var isSubmitTapped = false // Track if the submit button is tapped
    var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                Button(action: {
                    isSubmitTapped = true
                }) {
                    Text("Submit")
                }
                .padding()
            } else {
                Button(action: {
                    showImagePicker = true
                }) {
                    Text("Add Photo")
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            CameraView(isImageSelected: $isImageSelected, image: $image)
                .onDisappear {
                    // Check if an image is selected before dismissing
                    if !isImageSelected && !isSubmitTapped {
                        showImagePicker = false
                    }
                }
        }
        .onChange(of: isSubmitTapped) { newValue in
            if newValue {
                // Handle the submission action here, e.g., save the image or perform any necessary processing
                // Dismiss the view
                showImagePicker = false
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isImageSelected: Bool // Track if an image is selected
    @Binding var image: Image?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = .camera
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: image)
                parent.isImageSelected = true // Set the flag to true when an image is selected
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PostCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PostCreationView()
    }
}
