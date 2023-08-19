//  ListedEvent.swift
//  Slide
//  Created by Ethan Harianto on 8/1/23.

import CoreLocation
import FirebaseFirestore
import SwiftUI

struct ListedEvent: View {
    @Binding var event: Event
    @Binding var selectedEvent: Event
    @Binding var eventView: Bool
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none // You can choose a different style here
        dateFormatter.timeStyle = .short // You can choose a different style here
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            Image(systemName: event.icon)
                .imageScale(.large)
            VStack(alignment: .leading) {
                Text(event.name)
                    .fontWeight(.semibold)
                if !event.eventDescription.isEmpty {
                    Text(event.eventDescription)
                }
                Text(formatDate(date: event.start) + " - " + formatDate(date: event.end))
            }
            Spacer()
            Button {
                withAnimation {
                    selectedEvent = event
                    eventView.toggle()
                }
            }
            label: {
                Image(systemName: "chevron.right")
            }
        }
        .onTapGesture {
            withAnimation {
                selectedEvent = event
                eventView.toggle()
            }
        }
        .bubbleStyle(color: .primary)
    }
}
