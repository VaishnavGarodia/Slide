//  EventDetails.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import UIKit
import FirebaseStorage


struct EventDetails: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var image: UIImage = .init()
    var event: Event
    var preview = false
    var fromMap = true
    @Binding var eventView: Bool
    @State private var profileView = false
    @State private var selectedUser: UserData? = nil
    @State private var isRSVPed = false
    @State private var isLoading = false
    @State private var username = ""
    @State private var photoURL = ""
    @State private var showDescription = false
    @State private var showAttendeesSheet = false
    @State private var friendSlides: [String] = []
    @State private var nonFriendSlides: [String] = []
    @State private var showEventEditSheet = false
    @State private var bannerImage: UIImage = UIImage()
    @State var showEditButton: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                // Display event details here based on the 'event' parameter
                // For example:

                HStack {
                    if !fromMap {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(.leading)
                        }

                    } else {
                        Button {
                            withAnimation {
                                eventView.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(.leading)
                        }
                    }
                    Spacer()
                    if !event.bannerURL.isEmpty && image != UIImage() {
                        Image(systemName: event.icon)
                            .imageScale(.large)
                    }

                    Text(event.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    if showEditButton && event.hostUID == Auth.auth().currentUser!.uid && event.start > Date() {
                        // Then display the edit button
                        Button(action: {
                            showEventEditSheet.toggle()
                        }) {
                            Image(systemName: "pencil")
                                .imageScale(.large)
                                .padding(.trailing)
                        }
                    }
                }
                .padding()

                Group {
                    Capsule()
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                        .foregroundColor(.primary)
                    ZStack {
                        if !event.bannerURL.isEmpty {
                            EventBanner(imageURL: URL(string: event.bannerURL)!)
                                .cornerRadius(15)
                                .padding()
                        } else if image != UIImage() {
                            EventBanner(image: image)
                                .frame(width: UIScreen.main.bounds.width * 0.95)
                                .frame(maxHeight: UIScreen.main.bounds.width * 0.95 * 3 / 4)
                                .cornerRadius(15)
                                .padding()
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(colors: [.accentColor, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.95 * 3 / 4)
                            Image(systemName: event.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
                        }
                    }
                    .shadow(radius: 15)

                    Capsule()
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                        .foregroundColor(.primary)
                }

                HStack {
                    UserProfilePictures(photoURL: photoURL, dimension: 25)
                        .padding(.trailing, -5)
                    Text(username)
                        .fontWeight(.semibold)
                }
                .onTapGesture {
                    selectedUser = UserData(userID: event.hostUID, username: username, photoURL: photoURL)
                    profileView.toggle()
                }

                Text(formatDate(date: event.start) + " - " + formatDate(date: event.end))
                    .font(.callout)

                HStack {
                    Image(systemName: "mappin")
                    Text(event.address)
                        .multilineTextAlignment(.center)
                }

                Button {
                    withAnimation {
                        showDescription.toggle()
                    }
                } label: {
                    Text(showDescription ? "Hide Description" : "Show Description").font(.caption).foregroundColor(.gray)
                }

                if showDescription {
                    Text(event.eventDescription)
                        .font(.caption)
                }

                if event.hostUID != Auth.auth().currentUser!.uid && !preview {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            BackgroundComponent()
                            DraggingComponent(isRSVPed: $isRSVPed, isLoading: isLoading, maxWidth: geometry.size.width)
                        }
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                    .onChange(of: isRSVPed) { isRSVPed in
                        guard !isRSVPed else { return }
                        simulateRequest()
                    }
                    if showDescription {
                        Text(event.eventDescription)
                    }
                }
                Group {
                    Text("Attendees")
                    ScrollView(.horizontal) {
                        HStack(spacing: 16) { // Adjust spacing as needed
                            ForEach(friendSlides, id: \.self) { friendID in
                                UserSlidedProfileBox(uid: friendID, friend: true)
                            }
                            ForEach(nonFriendSlides, id: \.self) { nonFriendID in
                                UserSlidedProfileBox(uid: nonFriendID, friend: false)
                            }
                        }
                        .padding(.horizontal) // Add some padding to the HStack
                        // Start the new stuff (First section is gonna be fellow slides)
                    }
                }
            }
        }
        .padding()
        .scrollIndicators(.never)
        .onAppear {
            isRSVPed = event.slides.contains(Auth.auth().currentUser?.uid ?? "")
            extractFriendSlides(event: event) { friendSlidesTemp, nonFriendSlidesTemp in
                self.friendSlides = friendSlidesTemp
                self.nonFriendSlides = nonFriendSlidesTemp
            }
            fetchUsernameAndPhotoURL(for: event.hostUID) { temp, temp2 in
                username = temp!
                photoURL = temp2!
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showAttendeesSheet) {
            SlidesView(nonFriendsList: nonFriendSlides, friendsList: friendSlides)
        }
        .sheet(isPresented: $showEventEditSheet) {
            EventEditView(event: event, destination: event.coordinate)
        }
        .fullScreenCover(isPresented: $profileView) {
            UserProfileView(user: $selectedUser)
        }
    }
                         

    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d h:mm a"
        return dateFormatter.string(from: date)
    }

    private func simulateRequest() {
        isLoading = true
        let userID = Auth.auth().currentUser!.uid
        let eventID = event.id
        let eventDoc = db.collection("Events").document(eventID)
        let userDoc = db.collection("Users").document(userID)

        // Update user's SLIDES array
        userDoc.getDocument { userDocument, error in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }

            var slidesArray: [String] = []

            if let userData = userDocument?.data(),
               let existingSlides = userData["SLIDES"] as? [String]
            {
                slidesArray = existingSlides
            }

            if slidesArray.contains(eventID) {
                slidesArray.removeAll { $0 == eventID }
            } else {
                slidesArray.append(eventID)
            }

            userDoc.setData(["SLIDES": slidesArray], merge: true) { error in
                if let error = error {
                    print("Error updating user document: \(error)")
                }
            }
        }

        // Update event's SLIDES array
        eventDoc.getDocument { eventDocument, error in
            if let error = error {
                print("Error getting event document: \(error)")
                return
            }

            var slidesArray: [String] = []

            if let eventData = eventDocument?.data(),
               let existingSlides = eventData["SLIDES"] as? [String]
            {
                slidesArray = existingSlides
            }

            if slidesArray.contains(userID) {
                slidesArray.removeAll { $0 == userID }
            } else {
                slidesArray.append(userID)
            }

            userDoc.setData(["SLIDES": slidesArray], merge: true) { error in
                if let error = error {
                    print("Error updating user document: \(error)")
                }
            }
            eventDoc.setData(["SLIDES": slidesArray], merge: true) { error in
                if let error = error {
                    print("Error updating user document: \(error)")
                }
            }
        }

        isLoading = false
    }
}
