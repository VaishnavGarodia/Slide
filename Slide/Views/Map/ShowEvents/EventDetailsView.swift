//  EventDetailsView.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import SwiftUI
import FirebaseFirestore

struct EventDetailsView: View {
    var image: UIImage = .init()
    var bannerURL: String
    var icon: String
    var name: String
    var description: String
    var host: String
    var hostName: String
    var start: Date
    var end: Date

    var body: some View {
        VStack {
            // Display event details here based on the 'event' parameter
            // For example:
            if !bannerURL.isEmpty {
                EventBanner(imageURL: URL(string: bannerURL)!)
                    .cornerRadius(15)
            } else if image != UIImage() {
                EventBanner(image: image)
                    .frame(width: UIScreen.main.bounds.width / 2.5)
                    .frame(maxHeight: 4 * UIScreen.main.bounds.width / 7.5)
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
            Text(hostName)
            HStack {
                Text(formatDate(date: start))
                Text(formatDate(date: end))
            }
            Spacer()
        }
        .padding(16)
    }
    
    func formatDate(date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short // You can choose a different style here
            dateFormatter.timeStyle = .short // You can choose a different style here
            return dateFormatter.string(from: date)
        }
}
