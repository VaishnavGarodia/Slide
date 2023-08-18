// CreateEventPage.swift
// Slide
// Created by Vaishnav Garodia

import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MapKit
import PhotosUI
import SwiftUI

struct CreateEventPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isPhotoLibraryAuthorized = false
    @State private var map = MKMapView()
    @State private var event = Event()
    @State private var destination: CLLocationCoordinate2D!
    @State private var show = false
    @State private var createEventSearch: Bool = true
    @State private var alert = false
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage? = UIImage()
    @State private var wasSelected: Bool = false
    @State private var isShowingPreview = false
    @State private var icon = 0
    let icons = ["party.popper", "balloon.2", "birthday.cake", "book", "dice", "basketball", "soccerball", "football", "figure.climbing", "theatermasks", "beach.umbrella", "gamecontroller"]
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    var body: some View {
        ZStack {
            CreateEventView(map: $map, event: $event, alert: $alert, show: $show, destination: $destination)
                .ignoresSafeArea()
            
            if self.destination != nil && self.show {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundColor(.black.opacity(0.65))
            }
            VStack(alignment: .center) {
                if !self.show {
                    ZStack(alignment: .topTrailing) {
                        SearchView(map: $map, location: self.$destination, event: self.$event, detail: self.$show, createEventSearch: self.createEventSearch, frame: 280)
                            .padding(.top, -15)
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .padding()
                        }
                    }
                }
                if self.destination != nil && self.show {
                    VStack(alignment: .leading) {
                        Button(action: {
                            withAnimation {
                                self.map.removeOverlays(self.map.overlays)
                                self.map.removeAnnotations(self.map.annotations)
                                self.destination = nil
                                self.show.toggle()
                            }
                        }) {
                            Text("Cancel")
                                .padding()
                        }
                            
                        HStack {
                            Text("Banner")
                            Spacer()
                            Button {
                                isShowingImagePicker.toggle()
                            } label: {
                                if selectedImage == UIImage() {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(colors: [.accentColor, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 50, height: 50)
                                } else {
                                    Image(uiImage: selectedImage!)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Section {
                            TextField("What's your event called?", text: self.$event.name)
                                .checkMarkTextField()
                                .bubbleStyle(color: .primary)
                                .padding(.horizontal)
                        } header: {
                            Text("Name")
                                .padding(.horizontal)
                        }
                        .padding(.bottom)

                        Section {
                            TextField("What's happening at your event? (Optional)", text: self.$event.eventDescription, axis: .vertical)
                                .lineLimit(2, reservesSpace: true)
                                .checkMarkTextField()
                                .bubbleStyle(color: .primary)
                                .padding(.horizontal)
                        } header: {
                            Text("Description")
                                .padding(.horizontal)
                        }
                        .padding(.bottom)
                        
                        Section {
                            TextField("Where's your event at?", text: self.$event.address, axis: .vertical)
                                .lineLimit(2, reservesSpace: true)
                                .checkMarkTextField()
                                .bubbleStyle(color: .primary)
                                .padding(.horizontal)
                        } header: {
                            Text("Address")
                                .padding(.horizontal)
                        }
                        .padding(.bottom)
                         
                        DatePicker("Start Time", selection: self.$event.start, in: Date()...)
                            .onAppear {
                                UIDatePicker.appearance().minuteInterval = 15
                            }
                            .datePickerStyle(.compact)
                            .padding(.horizontal)
                        
                        DatePicker("End Time", selection: self.$event.end, in: self.event.start...)
                            .onAppear {
                                UIDatePicker.appearance().minuteInterval = 15
                            }
                            .padding(.horizontal)
                        
                        HorizontalPicker($icon, items: icons) { icon in
                            GeometryReader { reader in
                                Image(systemName: icon)
                                    .frame(width: reader.size.width, height: reader.size.height, alignment: .center)
                            }
                        }
                        .scrollAlpha(0.3)
                        .frame(height: 30)

                        Button(action: {
                            self.event.coordinate = CLLocationCoordinate2D(latitude: self.destination.latitude, longitude: self.destination.longitude)
                            self.isShowingPreview = true
                        }) {
                            Text("Create Event")
                                .foregroundColor(.white)
                                .filledBubble()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, wasSelected: wasSelected)
                .onAppear {
                    checkPhotoLibraryPermission()
                    if !isPhotoLibraryAuthorized {
                        requestPhotoLibraryPermission()
                    }
                }
        }
        .fullScreenCover(isPresented: $isShowingPreview) {
            VStack {
                EventDetails(
                    image: selectedImage ?? UIImage(),
                    event: event,
                    preview: true,
                    eventView: .constant(false)
                )
                Button(action: {
                    self.createEvent()
                }) {
                    Text("Publish Event")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(width: UIScreen.main.bounds.width / 2)
                }
                .filledBubble()
                .padding()
            }
        }
    }
    
    func createEvent() {
        let doc = db.collection("Events").document()
        print("Creating event for location: ", event.coordinate)
        
        doc.setData(["HostUID": Auth.auth().currentUser!.uid, "Name": event.name, "Description": event.description, "Icon": icons[icon], "Host": Auth.auth().currentUser!.displayName!, "Address": event.address, "Coordinate": GeoPoint(latitude: event.coordinate.latitude, longitude: event.coordinate.longitude), "Start": event.start, "End": event.end, "Hype": "low", "Associated Highlights": [String]()]) { err in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            } else {
                uploadBannerToFirebaseStorage(image: selectedImage ?? UIImage(), documentID: doc.documentID)
            }
        }
        
        let userDoc = db.collection("Users").document(Auth.auth().currentUser!.uid)
        userDoc.updateData(["Events": FieldValue.arrayUnion([doc.documentID])]) { error in
            if let error = error {
                print("Error updating events array: \(error)")
            } else {
                print("Events array updated successfully!")
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
        
    func uploadBannerToFirebaseStorage(image: UIImage, documentID: String) {
        guard let imageData = compressImageToTargetSize(image, targetSizeInKB: 100) else {
            print("Failed to compress image.")
            return
        }
        let storageRef = storage.reference().child("EventBanners/\(documentID).jpg")
        let uploadTask = storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else if let downloadURL = url {
                        // Update the post document with the image download URL
                        let postDocumentRef = db.collection("Events").document(documentID)
                        postDocumentRef.updateData(["Event Image": downloadURL.absoluteString]) { error in
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
    
struct CreateEventPage_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventPage()
    }
}
