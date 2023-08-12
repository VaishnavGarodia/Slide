//  EventDetailsView.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import SwiftUI

struct EventDetailsView: View {
    var event: EventData

    var body: some View {
        VStack {
            // Display event details here based on the 'event' parameter
            // For example:
            if !event.bannerURL.isEmpty {
                EventBanner(imageURL: URL(string: event.bannerURL)!)
                    .cornerRadius(15)
            }
            HStack {
                Image(systemName: event.icon)
                    .imageScale(.large)
                Text(event.name)
                    .font(.title)
            }
            
            Text(event.eventDescription)
                .font(.body)
            // ... (display other details as needed)
            Text(event.host)
            HStack {
                Text(event.start)
                Text(event.end)
            }
            Spacer()
        }
        .padding(16)
    }
}
