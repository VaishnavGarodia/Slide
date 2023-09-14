//  UserSearchResults.swift
//  Slide
//  Created by Ethan Harianto on 7/30/23.

import SwiftUI

struct UserSearchResults: View {
    @Binding var searchResults: [UserData]
    @State private var showingConfirmationDialog = false
    @State private var tapped = false
    @State private var isPresented = false
    @State private var selectedUser: UserData? = nil

    var body: some View {
        ForEach(searchResults, id: \.userID) { friend in
            HStack {
                UserProfilePictures(photoURL: friend.photoURL, dimension: 40)
                Text(friend.username)
                    .foregroundColor(.white)

                Spacer()
                Button {
                    withAnimation {
                        sendFriendRequest(selectedUser: friend)
                        tapped.toggle()
                    }
                } label: {
                    Text(tapped ? "Requested" : "Request")
                        .foregroundColor(tapped ? .gray : .primary)
                        .padding(tapped ? 2.5 : 5)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(tapped ? .primary : .accentColor))
                }
            }
            .onTapGesture {
                selectedUser = friend
                isPresented.toggle()
            }
            .onAppear {
                tapped = friend.added ?? false
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .sheet(isPresented: $isPresented) {
            UserProfileView(user: $selectedUser)
        }
    }
}

struct UserSearchResults_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchResults(searchResults: .constant([UserData(userID: "mwahah", username: "baesuzy", photoURL: "https://m.media-amazon.com/images/M/MV5BZWQ5YTFhZDAtMTg3Yi00NzIzLWIyY2EtNDQ2YWNjOWJkZWQxXkEyXkFqcGdeQXVyMjQ2OTU4Mjg@._V1_.jpg", added: false), UserData(userID: "mwahahah", username: "tomholland", photoURL: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", added: false)]))
    }
}
