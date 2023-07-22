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

