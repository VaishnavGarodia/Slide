//  EventDetails.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI
import UIKit

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
    @State private var bannerImage: UIImage = .init()
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
                            Image(systemName: "chevron.left.circle")
                                .imageScale(.large)
                                .padding(.leading)
                        }
                    } else {
                        Button {
                            withAnimation {
                                eventView.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.left.circle")
                                .imageScale(.large)
                                .padding(.leading)
                        }
                    }
                    Spacer()
                    if !event.bannerURL.isEmpty || image != UIImage() {
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
                    } else {
                        UserProfilePictures(photoURL: photoURL, dimension: 35)
                            .padding(.trailing)
                            .onTapGesture {
                                if username != Auth.auth().currentUser?.displayName && !preview {
                                    selectedUser = UserData(userID: event.hostUID, username: username, photoURL: photoURL)
                                    profileView.toggle()
                                }
                            }
                    }
                }
                .padding()

                Group { // EventBanner
                    Capsule()
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                        .foregroundColor(.primary)
                    ZStack {
                        if !event.bannerURL.isEmpty {
                            EventBanner(imageURL: URL(string: event.bannerURL)!)
                                .cornerRadius(15)
                                .padding()
                        } else if image != UIImage() {
                            Image(uiImage: image)

                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.95 * 3 / 4)
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
                VStack {
                    Text(formatDate(date: event.start) + " - " + formatDate(date: event.end))
                        .font(.callout)

                    HStack {
                        Image(systemName: "mappin")
                        Text(event.address)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        withAnimation {
                            showDescription.toggle()
                        }
                    } label: {
                        Text(showDescription ? "Hide Description" : "Show Description").font(.caption).foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }

                    if showDescription {
                        Text(event.eventDescription)
                            .font(.caption)
                    }
                }
                .padding()

                Group {
                    UserSlidedProfileBox(friendSlides: friendSlides, strangerSlides: nonFriendSlides)
                        .padding(.horizontal) // Add some padding to the HStack
                }

                if event.hostUID != Auth.auth().currentUser!.uid && !preview {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            BackgroundComponent()
                            DraggingComponent(isRSVPed: $isRSVPed, isLoading: isLoading, maxWidth: geometry.size.width)
                        }
                    }
                    .frame(height: 50)
                    .padding()
                    .onChange(of: isRSVPed) { isRSVPed in
                        print("we out here")
                        simulateRequest()
                    }
                }
            }
        }
        .padding()
        .scrollIndicators(.never)
        .onAppear {
            isRSVPed = event.slides.contains(Auth.auth().currentUser?.uid ?? "")
            if !preview {
                extractFriendSlides(event: event) { friendSlidesTemp, nonFriendSlidesTemp in
                    self.friendSlides = friendSlidesTemp
                    self.nonFriendSlides = nonFriendSlidesTemp
                }
                fetchUsernameAndPhotoURL(for: event.hostUID) { temp, temp2 in
                    username = temp!
                    photoURL = temp2!
                }
            } else {
                username = (Auth.auth().currentUser?.displayName)!
                photoURL = Auth.auth().currentUser?.photoURL?.absoluteString ?? ""
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showAttendeesSheet) {
            SlidesView(nonFriendsList: nonFriendSlides, friendsList: friendSlides)
        }
        .sheet(isPresented: $showEventEditSheet) {
            EventEditView(showEventEditSheet: $showEventEditSheet, event: event, destination: event.coordinate)
        }
        .fullScreenCover(isPresented: $profileView) {
            UserProfileView(user: $selectedUser)
        }
    }

    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, h:mm a"
        return dateFormatter.string(from: date)
    }

    private func simulateRequest() {
        isLoading = true
        let userID = Auth.auth().currentUser!.uid
        let eventID = event.id
        let eventDoc = db.collection("Events").document(eventID)
        let userDoc = db.collection("Users").document(userID)
        
        var needsNoti = true
        
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
                needsNoti = false

            } else {
                slidesArray.append(eventID)
                needsNoti = true
            }
            print(needsNoti)
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
            
            if needsNoti,
               let eventData = eventDocument?.data() {
                print("All the way")
                let name = eventData["Name"] as? String ?? ""
//                let description = eventData["Description"] as? String ?? ""
                let eventID = eventDocument!.documentID
                if let start = (eventData["Start"] as? Timestamp)?.dateValue() {
                    print("more")
                    let identifier = eventID + "|" + userID
                    let title = "Starting Soon!"
                    let body = name + " is starting soon"
                    
                    let notificationCenter = UNUserNotificationCenter.current()
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    content.sound = .default
                    
                    
                    let calendar = Calendar.current
                    let start20 = calendar.date(byAdding: .minute, value: -20, to: start)
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: start20!)
                    let year = components.year
                    let month = components.month
                    let day = components.day
                    let hour = components.hour
                    let minute = components.minute

                    var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
                    
                    dateComponents.year = year
                    dateComponents.month = month
                    dateComponents.day = day
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                                        
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    
//                    you might think you're being clean, but do us all a favor and don't delete this
//                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                    notificationCenter.add(request)
                    print("Added")
                }
            }
        }
        
        isLoading = false
    }
}
