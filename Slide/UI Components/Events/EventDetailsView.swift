//  EventDetailsView.swift
//  Slide
//  Created by Ethan Harianto on 8/18/23.

import SwiftUI

struct EventDetailsView: View {
    @State private var selectedTab = 0
    @Binding var event: Event
    @Binding var eventView: Bool
    var gallery: Bool = true

    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                EventDetails(event: event, eventView: $eventView, fromMap: true)
                Spacer()
            }
            if gallery && !event.highlights.isEmpty {
                EventGallery(eventID: event.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
