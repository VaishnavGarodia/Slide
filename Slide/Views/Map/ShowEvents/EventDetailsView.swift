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
            Image(systemName: event.icon)
            Text(event.name)
                .font(.title)
            Text(event.description)
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
