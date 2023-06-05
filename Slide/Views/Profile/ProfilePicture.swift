//
//  SwiftUIView.swift
//  Slide
//
//  Created by Ethan Harianto on 6/5/23.
//

import SwiftUI

struct ProfilePictureView: View {
    let profilePictureURL: URL?
    
    var body: some View {
        Group {
            if let url = profilePictureURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                }
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
            }
        }
    }
}


