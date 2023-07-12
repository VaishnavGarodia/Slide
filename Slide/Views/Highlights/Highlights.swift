//
//  Highlights.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

struct HighlightInfo: Identifiable {
    var id = UUID()
    var imageName: String
    var profileImageName: String
    var username: String
    var highlightTitle: String
}

struct Highlights: View {
    @State private var highlights: [HighlightInfo] = [
        HighlightInfo(imageName: "Highlight1", profileImageName: "ProfilePic2", username: "Zendaya", highlightTitle: "Spider-Man Photoshoot"),
    ]

    var body: some View {
        VStack {
            NavigationLink(destination: PostCreationView()) {
                Image(systemName: "person")
                    .padding()
                    .imageScale(.large)
            }.foregroundColor(.white)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(highlights) { highlight in
                        HighlightCard(highlight: highlight)
                    }
                }
                .padding()
            }
        }
    }
}

struct HighlightCard: View {
    var highlight: HighlightInfo

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width: 400, height: 500)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

            Image(highlight.imageName)
                .resizable()
                .clipped()
                .clipShape(Rectangle())
                .frame(width: 400, height: 400)

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

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        Highlights()
    }
}
