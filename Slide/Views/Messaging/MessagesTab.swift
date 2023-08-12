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
                .padding(5)
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
            .padding(.bottom, -10)
            .padding(.top, -10)

            List {
                ForEach(vm.recentMessages.keys.sorted(), id: \.self) { chatUserId in
                    if let messages = vm.recentMessages[chatUserId] {
                        if let recentMessage = messages.last {
                            RecentMessageRow(recentMessage: recentMessage, profileView: $profileView, selectedUser: $selectedUser)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        onHide(message: recentMessage)
                                    } label: {
                                        Label("", systemImage: "trash")
                                    }
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

    func onHide(message: RecentMessage) {
        vm.hideMessage(message)
    }
}

struct MessagesTab_Previews: PreviewProvider {
    static var previews: some View {
        MessagesTab()
    }
}
