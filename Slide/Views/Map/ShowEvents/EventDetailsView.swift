//  EventDetailsView.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import SwiftUI

struct EventDetailsView: View {
    var image: UIImage = .init()
    var bannerURL: String
    var icon: String
    var name: String
    var description: String
    var host: String
    var start: String
    var end: String

    var body: some View {
        VStack {
            // Display event details here based on the 'event' parameter
            // For example:
            if image != UIImage() {
                // TODO: Ethan please fix display here. This is what will display when we use preview since we haven't technically uploaded to firebase yet.
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width / 2.5 , height: 4 * UIScreen.main.bounds.width / 7.5)
            }
            else if !bannerURL.isEmpty {
                EventBanner(imageURL: URL(string: bannerURL)!)
                    .cornerRadius(15)
            }
            HStack {
                Image(systemName: icon)
                    .imageScale(.large)
                Text(name)
                    .font(.title)
            }

            Text(description)
                .font(.body)
            // ... (display other details as needed)
            Text(host)
            HStack {
                Text(start)
                Text(end)
            }
            Spacer()
        }
        .padding(16)
    }
}
