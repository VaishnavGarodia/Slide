//  ListedEvent.swift
//  Slide
//  Created by Ethan Harianto on 8/1/23.

import SwiftUI
import CoreLocation
import FirebaseFirestore

struct ListedEvent: View {
    @State private var expanded = false
    @Binding var event: EventData
    @Binding var selectedEvent: EventData
    var body: some View {
        HStack {
            Image(systemName: event.icon)
                .imageScale(.large)
            VStack(alignment: .leading) {
                Text(event.name)
                    .fontWeight(.semibold)
                Text(event.eventDescription)
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
        ListedEvent(event: .constant(EventData(name: "Tom Holland's Party", description: "We vibin", host: "tomholland", hostName: "tomholland", address: "ur mum's house", start: Timestamp(), end: Timestamp(), hostUID: "madadasdwas", icon: "party.popper", coordinate: CLLocationCoordinate2D(), bannerURL: "")), selectedEvent: .constant(EventData(name: "Tom Holland's Party", description: "We vibin", host: "tomholland", hostName: "tomholland", address: "ur mum's house", start: Timestamp(), end: Timestamp(), hostUID: "madadasdwas", icon: "party.popper", coordinate: CLLocationCoordinate2D(), bannerURL: "")))
    }
}
