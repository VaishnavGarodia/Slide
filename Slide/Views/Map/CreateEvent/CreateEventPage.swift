//
// MapPage.swift
// Slide
//
// Created by Vaishnav Garodia
//
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import MapKit
import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage

struct CreateEventPage: View {
    @State private var isPhotoLibraryAuthorized = false
    @State private var map = MKMapView()
    @State var event = Event(name: "", description: "", eventIcon: "", host: "", start: Date.now, end: Date.now.addingTimeInterval(3600), address: "", location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), bannerURL: "")
    @State var destination: CLLocationCoordinate2D!
    @State var show = false
    @State private var createEventSearch: Bool = true
    @State var alert = false
    
    
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage? = UIImage()
    @State private var wasSelected: Bool = false
    
    
    var body: some View {
        ZStack {
            CreateEventView(map: $map, event: $event, alert: $alert, show: $show)
                .ignoresSafeArea()

            if self.destination != nil && self.show {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundColor(.black.opacity(0.5))
            }
            VStack {
                VStack(alignment: .center) {
                    HStack {
                        ZStack(alignment: .topLeading) {
                            SearchView(map: $map, location: self.$destination, event: self.event, detail: self.$show, createEventSearch: self.createEventSearch, frame: 280)
                                .padding(.top, -15)
                        }
                    }
                    if self.destination != nil && self.show {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Event Banner")
                                    if selectedImage == UIImage()  {
                                        Spacer()
                                    } else {
                                        Text("Image Has Been Selected")
                                    }
                                }
                                .onTapGesture {
                                    isShowingImagePicker.toggle()
                                }
                                TextField("Event Name", text: self.$event.name)
                                    .bubbleStyle(color: .primary)
                                    .padding(.top)
                                TextField("Event Description", text: self.$event.description, axis: .vertical)
                                    .frame(height: 50, alignment: .topLeading)
                                    .bubbleStyle(color: .primary)
                                TextField("Address", text: self.$event.address, axis: .vertical)
                                    .frame(height: 50, alignment: .topLeading)
                                    .bubbleStyle(color: .primary)
                                DatePicker("Event Start", selection: self.$event.start, in: Date()...)
                                    .onAppear {
                                        UIDatePicker.appearance().minuteInterval = 15
                                    }
                                    .datePickerStyle(.compact)
                                DatePicker("Event End", selection: self.$event.end, in: self.event.start...)
                                    .onAppear {
                                        UIDatePicker.appearance().minuteInterval = 15
                                    }
                                Picker("Event Icon", selection: self.$event.eventIcon) {
                                    Image(systemName: "figure.basketball").tag("figure.basketball")
                                    Image(systemName: "party.popper").tag("party.popper")
                                    Image(systemName: "theatermasks").tag("theatermasks")
                                }
                                .pickerStyle(.segmented)
                                Button(action: {
//                                    self.loading.toggle()
                                    self.event.location = CLLocationCoordinate2D(latitude: self.destination.latitude, longitude: self.destination.longitude)
                                    self.createEvent()
                                }) {
                                    Text("Create Event")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .frame(width: UIScreen.main.bounds.width / 2)
                                }
                                .filledBubble()
                                .padding()
                            }
                            Button(action: {
                                self.map.removeOverlays(self.map.overlays)
                                self.map.removeAnnotations(self.map.annotations)
                                self.destination = nil
                                self.show.toggle()
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()
                    }
                }
                Spacer()
//                if self.loading {
//                    Loader()
//                }
//                if self.book {
//                    Booked(data: self.$data, doc: self.$doc, loading: self.$loading, book: self.$book)
//                }
            }
        }
//        .alert(isPresented: self.$alert) { () -> Alert in
//            Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
//        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, wasSelected: wasSelected)
                .onAppear {
                    UITabBar.appearance().unselectedItemTintColor = nil
                    UITabBar.appearance().isTranslucent = true
                    UITabBar.appearance().backgroundColor = nil
                    
                    checkPhotoLibraryPermission()
                    if !isPhotoLibraryAuthorized {
                        requestPhotoLibraryPermission()
                    }
                }
//                .onDisappear {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 86400) {
//                        isShowingImagePicker = false
//                        UITabBar.appearance().unselectedItemTintColor = .white
//                        UITabBar.appearance().isTranslucent = false
//                        UITabBar.appearance().backgroundColor = .black
//                    }
//                }
        }
    }

    func createEvent() {
        let doc = db.collection("Events").document()
//        self.doc = doc.documentID
        print("Creating event for location: ", self.event.location)
                
        doc.setData(["HostUID": Auth.auth().currentUser!.uid, "Name": self.event.name, "Description": self.event.description, "Icon": self.event.eventIcon, "Host": Auth.auth().currentUser!.displayName!, "Address": self.event.address, "Location": GeoPoint(latitude: self.event.location.latitude, longitude: self.event.location.longitude)]) { err in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            } else {
                uploadBannerToFirebaseStorage(image: selectedImage ?? UIImage(), documentID: doc.documentID)
            }
//            self.loading.toggle()
//            self.book.toggle()
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
        let storageRef = Storage.storage().reference().child("EventBanners/\(documentID).jpg")
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
