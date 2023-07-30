//
//  HighlightCard.swift
//  Slide
//
//  Created by Ethan Harianto on 7/20/23.
//

import SwiftUI
import UIKit

struct HighlightCard: View {
    var highlight: HighlightInfo

    var body: some View {
        ZStack {
            // Use AsyncImage to fetch and display the image
            AsyncImage(url: URL(string: highlight.imageName)) { phase in
                switch phase {
                case .empty:
                    // Placeholder view while loading
                    ProgressView()
                case .success(let image):

                    // The actual image loaded successfully
                    HighlightImage(uiImage: image.asUIImage())

                case .failure(let error):
                    // In case of an error, you can show an error placeholder or message
                    Text("Error loading image: \(error.localizedDescription)")
                @unknown default:
                    // Placeholder view while loading (handles potential future changes)
                    ProgressView()
                }
            }

            VStack {
                HStack {
                    HStack {
                        UserProfilePictures(photoURL: highlight.profileImageName, dimension: 35)
                        VStack (alignment: .leading){
                            Text(highlight.username)
                                .foregroundColor(.white)
                            Text(highlight.highlightTitle)
                                .font(.caption)
                                .fontWeight(.thin)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 5)
                    .background(RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.black.opacity(0.5)))
                    .padding(5)

                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.white)
                            .imageScale(.medium)
                            .padding()
                            .background(Circle()
                                .foregroundColor(.black.opacity(0.5)))
                        Image(systemName: "bookmark")
                            .foregroundColor(.white)
                            .imageScale(.medium)
                            .padding()
                            .background(Circle()
                                .foregroundColor(.black.opacity(0.5)))
                    }
                    .padding(5)
                }
            }
        }
    }
}

struct SmallHighlightCard: View {
    var highlight: HighlightInfo

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Use AsyncImage to fetch and display the image
            AsyncImage(url: URL(string: highlight.imageName)) { phase in
                switch phase {
                case .empty:
                    // Placeholder view while loading
                    ProgressView()
                case .success(let image):
                    // The actual image loaded successfully
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                case .failure(let error):
                    // In case of an error, you can show an error placeholder or message
                    Text("Error loading image: \(error.localizedDescription)")
                @unknown default:
                    // Placeholder view while loading (handles potential future changes)
                    ProgressView()
                }
            }

            VStack(alignment: .leading) {
                Spacer()
                Text(highlight.highlightTitle)
                    .padding(2) // Add some padding to increase the frame size
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10) // Add corner radius to make it rounded
            }
        }
        .padding()
    }
}
