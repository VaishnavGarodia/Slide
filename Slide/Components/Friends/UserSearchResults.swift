//  UserSearchResults.swift
//  Slide
//  Created by Ethan Harianto on 7/30/23.

import SwiftUI

struct UserSearchResults: View {
    @Binding var searchResults: [UserData]
    @State private var showingConfirmationDialog = false

    var body: some View {
        Section {
            List(searchResults, id: \.userID) { friend in
                HStack {
                    UserProfilePictures(photoURL: friend.photoURL, dimension: 40)
                    Text(friend.username)
                        .foregroundColor(.white)

                    Spacer()
                    if friend.added ?? false {
                        Button {} label: {
                            HStack {
                                Text("Added")
                            }
                            .padding(5)
                            .foregroundColor(.gray)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.primary))
                        }
                    }
                    else {
                        Button {
                            sendFriendRequest(selectedUser: friend)
                            if let index = searchResults.firstIndex(where: { $0.userID == friend.userID }) {
                                var updatedFriend = friend
                                updatedFriend.added = true
                                searchResults[index] = updatedFriend
                            }
                        } label: {
                            Text("Add")
                                .foregroundColor(.primary)
                                .padding(5)
                                .padding(.horizontal)
                                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.accentColor))
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        } header: {
            Text("Search Results")
                .padding(5)
        }
    }
}

struct UserSearchResults_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchResults(searchResults: .constant([UserData(userID: "mwahah", username: "baesuzy", photoURL: "https://m.media-amazon.com/images/M/MV5BZWQ5YTFhZDAtMTg3Yi00NzIzLWIyY2EtNDQ2YWNjOWJkZWQxXkEyXkFqcGdeQXVyMjQ2OTU4Mjg@._V1_.jpg", added: false), UserData(userID: "mwahahah", username: "tomholland", photoURL: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", added: false)]))
    }
}
