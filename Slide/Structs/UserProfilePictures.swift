//
//  UserProfilePictures.swift
//  Slide
//
//  Created by Ethan Harianto on 7/27/23.
//

import SwiftUI

struct UserProfilePictures: View {
    let photoURL: String
    let dimension: CGFloat
    var body: some View {
        if photoURL.isEmpty {
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: dimension, height: dimension)
                .padding(5)
                .clipShape(Circle())
        } else if let profileImageURL = URL(string: photoURL) {
            // Use AsyncImage to fetch and display the image
            AsyncImage(url: profileImageURL) { phase in
                switch phase {
                case .empty:
                    // Placeholder view while loading
                    ProgressView()
                case .success(let image):
                    // The actual image loaded successfully
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: dimension, height: dimension)
                        .padding(5)
                        .clipped()

                case .failure(let error):
                    // In case of an error, you can show an error placeholder or message
                    Text("Error loading image: \(error.localizedDescription)")
                        .frame(width: dimension, height: dimension)
                        .padding(5)
                @unknown default:
                    // Placeholder view while loading (handles potential future changes)
                    ProgressView()
                        .frame(width: dimension, height: dimension)
                        .padding(5)
                }
            }
        }
    }
}

struct UserProfilePictures_Previews: PreviewProvider {
    static var previews: some View {
        UserProfilePictures(photoURL: "https://static.foxnews.com/foxnews.com/content/uploads/2023/07/GettyImages-1495234870.jpg", dimension: 35)
    }
}
