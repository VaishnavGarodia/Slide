//
//  Highlights.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

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

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        Highlights()
    }
}
