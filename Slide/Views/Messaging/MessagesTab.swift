//  MessagesTab.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct MessagesTab: View {
    @State private var searchMessages = ""
    @State private var username = ""
    @State private var selectedUser: UserData? = nil
    @State private var profileView = false
    @State private var search: [String] = []

    @ObservedObject private var vm = MainMessagesViewModel()

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchMessages)
                }
                .checkMarkTextField()
                .bubbleStyle(color: .primary)
                .onChange(of: searchMessages) { _ in
                    searchMessagesByUsername(username: searchMessages.lowercased()) { users in
                        search = users
                    }
                }

                Spacer()
                NavigationLink(destination: AddFriendsView()) {
                    Image(systemName: "person.badge.plus")
                        .padding()
                        .imageScale(.medium)
                        .foregroundColor(.primary)
                }
                NavigationLink(destination: NewChat()) {
                    Image(systemName: "square.and.pencil")
                        .padding()
                        .imageScale(.medium)
                        .foregroundColor(.primary)
                }
            }

            List {
                ForEach(vm.recentMessages.keys.sorted(), id: \.self) { chatUserId in
                    if let messages = vm.recentMessages[chatUserId] {
                        if let recentMessage = messages.last {
                            if !search.isEmpty {
                                if search.contains(chatUserId) {
                                    RecentMessageRow(recentMessage: recentMessage, profileView: $profileView, selectedUser: $selectedUser)
                                }
                            } else {
                                RecentMessageRow(recentMessage: recentMessage, profileView: $profileView, selectedUser: $selectedUser, vm: vm)
                                    
                            }
                        }
                    }
                }
                .listStyle(.grouped)
                .listRowBackground(Color.darkGray)
            }
        }
        .fullScreenCover(isPresented: $profileView) {
            UserProfileView(user: $selectedUser)
        }
    }
}

struct MessagesTab_Previews: PreviewProvider {
    static var previews: some View {
        MessagesTab()
    }
}
