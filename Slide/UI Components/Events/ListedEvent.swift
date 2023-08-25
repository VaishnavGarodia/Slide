//  ListedEvent.swift
//  Slide
//  Created by Ethan Harianto on 8/1/23.

import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ListedEvent: View {
    @Binding var event: Event
    @Binding var selectedEvent: Event
    @Binding var eventView: Bool
    @State private var press = false

    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, h:mm a"
        return dateFormatter.string(from: date)
    }

    var body: some View {
        HStack {
            if event.bannerURL.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [.accentColor, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: UIScreen.main.bounds.width / 7.5, height: UIScreen.main.bounds.width / 7.5)
                    Image(systemName: event.icon)
                        .imageScale(.small)
                }
            } else {
                MiniEventBanner(imageURL: URL(string: event.bannerURL))
                    .cornerRadius(10)
            }

            VStack(alignment: .leading) {
                Text(event.name)
                    .fontWeight(.semibold)

                if !event.eventDescription.isEmpty {
                    Text(event.eventDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "clock")
                    Text(formatDate(date: event.start))
                        .font(.callout)
                }
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
