//
//  EventDetailsView.swift
//  Slide
//
//  Created by Vaishnav Garodia on 8/8/23.
//
import SwiftUI

struct EventDetailsView: View {
    var event: EventData

    var body: some View {
        VStack {
            // Display event details here based on the 'event' parameter
            // For example:
            Text(event.name)
                .font(.title)
            Text(event.description)
                .font(.body)
            // ... (display other details as needed)
            
            Spacer()
        }
        .padding(16)
    }
}
