import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct MessagesTab: View {
    @State private var searchMessages = ""
    @State private var username = ""
    @State private var selectedUser: UserData? = nil
    @State private var profileView = false
    @State private var search: [String] = []

    @ObservedObject var vm: MainMessagesViewModel

    var body: some View {
        VStack {
            // Nav bar section
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
            .padding()
            .padding(.bottom, -10)
            .padding(.top, -10)
            
            // Main Content
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Spacer(minLength: geometry.size.height/2 - 50)  // Adjust for vertical centering

                        if vm.recentMessages.isEmpty {
                            NoMessagesView()
                                .frame(width: geometry.size.width, alignment: .center)  // Force width to be the screen width and center content
                        } else {
                            ForEach(vm.recentMessages.keys.sorted(by: { chatUserId1, chatUserId2 -> Bool in
                                if let messages1 = vm.recentMessages[chatUserId1],
                                   let messages2 = vm.recentMessages[chatUserId2],
                                   let recentMessage1 = messages1.last,
                                   let recentMessage2 = messages2.last {
                                    return recentMessage1.timestamp.dateValue() > recentMessage2.timestamp.dateValue()
                                }
                                return false
                            }), id: \.self) { chatUserId in
                                if let messages = vm.recentMessages[chatUserId],
                                   let recentMessage = messages.last {
                                    if !search.isEmpty && search.contains(chatUserId) {
                                        RecentMessageRow(recentMessage: recentMessage, profileView: $profileView, selectedUser: $selectedUser, vm: vm)
                                    } else if searchMessages.isEmpty {
                                        RecentMessageRow(recentMessage: recentMessage, profileView: $profileView, selectedUser: $selectedUser, vm: vm)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: geometry.size.height/2 - 50)  // Adjust for vertical centering
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $profileView) {
            UserProfileView(user: $selectedUser)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

struct NoMessagesView: View {
    var body: some View {
        VStack {
            Text("Welcome to Messages!")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)  // Center align text
            Text("You don't have any messages yet. Start a conversation to see them here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)  // Center align text
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)  // This will stretch the VStack to use full available width
    }
}


struct MessagesTab_Previews: PreviewProvider {
    static var previews: some View {
        MessagesTab(vm: MainMessagesViewModel())
    }
}
