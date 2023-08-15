//  ListedEvent.swift
//  Slide
//  Created by Ethan Harianto on 8/1/23.

import SwiftUI
import CoreLocation
import FirebaseFirestore

struct ListedEvent: View {
    @State private var expanded = false
    @Binding var event: Event
    @Binding var selectedEvent: Event
    var body: some View {
        HStack {
            Image(systemName: event.icon)
                .imageScale(.large)
            VStack(alignment: .leading) {
                Text(event.title!)
                    .fontWeight(.semibold)
                Text(event.subtitle!)
            }
            Spacer()
            Button {
                self.selectedEvent = event
            }
            label: {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(expanded ? 90 : 0))
            }
        }
        .bubbleStyle(color: .primary)
    }
}

struct ListedEvent_Previews: PreviewProvider {
    static var previews: some View {
        ListedEvent(event: .constant(Event()), selectedEvent: .constant(Event()))
    }
}
