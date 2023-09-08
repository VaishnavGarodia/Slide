//
//  UserSlidedProfileBox.swift
//  Slide
//
//  Created by Thomas on 8/24/23.
//

import FirebaseAuth
import Kingfisher
import SwiftUI

struct UserSlidedProfileBox: View {
    let friendSlides: [String]
    let strangerSlides: [String]
    @State private var usernames: [String] = []
    @State private var profileURLs: [String] = []

    var body: some View {
        HStack {
            ForEach(Array(friendSlides.enumerated()), id: \.element) { index, _ in
                if index < profileURLs.count - 1 {
                    UserProfilePictures(photoURL: profileURLs[index], dimension: 25)
                        .padding()
                }
            }
        }
        .onAppear {
            fetchUserDatas()
        }
    }

    private func fetchUserDatas() {
        let group = DispatchGroup()

        for slide in friendSlides {
            group.enter()
            fetchUserData(uid: slide) { fetchedUsername, fetchedURL in
                defer {
                    group.leave()
                }
                if let username = fetchedUsername,
                   let photoURL = fetchedURL
                {
                    DispatchQueue.main.async {
                        usernames.append(username)
                        profileURLs.append(photoURL)
                    }
                }
            }
        }

        group.notify(queue: .main) {
            // All data has been fetched, you can update profileURLs here if needed
        }
    }

    private func fetchUserData(uid: String, completion: @escaping (String?, String?) -> Void) {
        fetchUsernameAndPhotoURL(for: uid) { fetchedUsername, fetchedProfilePicURL in
            completion(fetchedUsername, fetchedProfilePicURL)
        }
    }
}
