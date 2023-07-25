//
//  HighlightCard.swift
//  Slide
//
//  Created by Ethan Harianto on 7/20/23.
//

import SwiftUI

struct HighlightCard: View {
    var highlight: HighlightInfo

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width: 400, height: 500)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

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
                        .frame(width: 400, height: 400)
                        .clipped()

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
                    Image(highlight.profileImageName)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 35, height: 35)
                        .padding(7.5)

                    Text(highlight.username)

                    Spacer()

                    Text(highlight.highlightTitle)
                        .font(.caption)
                        .fontWeight(.thin)
                        .foregroundColor(Color.white)
                        .padding()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "bubble.left")
                        .imageScale(.medium)
                        .padding()
                    Image(systemName: "bookmark")
                        .imageScale(.medium)
                        .padding()
                }
            }
        }
        .padding(75)
    }
}
