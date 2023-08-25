//
//  UserSlidedProfileBox.swift
//  Slide
//
//  Created by Thomas on 8/24/23.
//

import SwiftUI
import Kingfisher

struct UserSlidedProfileBox: View {
    @State var uid: String
    @State var username: String = ""
    @State var profilePicUrl: String = ""
    @State var friend: Bool
    
    let boxSize: CGFloat = UIScreen.main.bounds.width / 3
    
    var body: some View {
        VStack {
            if (profilePicUrl != "") {
                KFImage(URL(string: profilePicUrl)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: boxSize, height: boxSize)
                    .clipShape(Circle())
            }
            //TODO: Add else case and populate with necessary placeholder
            Text(username)
                .font(.headline)
            if (friend) {
                Text("Friend")
            }
        }
        .frame(width: boxSize)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(boxSize / 2)
        .padding(.horizontal)
        .onAppear {
            fetchUserData()
        }
    }


    func fetchUserData() {
        fetchUsernameAndPhotoURL(for: self.uid) { fetchedUsername, fetchedProfilePicURL in
            DispatchQueue.main.async {
                self.username = fetchedUsername ?? ""
                self.profilePicUrl = fetchedProfilePicURL ?? ""
            }
        }
    }

}
