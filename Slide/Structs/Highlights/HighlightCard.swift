// HighlightCard.swift
// Slide
//
// Created by Ethan Harianto on 7/20/23.
//
import SwiftUI
import UIKit
import Kingfisher

struct HighlightCard: View {
  var highlight: HighlightInfo
  var body: some View {
    ZStack {
      HighlightImage(imageURL: URL(string: highlight.imageName)!)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 15))
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
      KFImage(URL(string: highlight.imageName))
        .resizable()
        .fade(duration: 0.25)
        .scaledToFill()
        .frame(width: 180, height: 180)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
