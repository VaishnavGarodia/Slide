//  MiniEventView.swift
//  Slide
//  Created by Thomas on 8/15/23.

import CoreLocation
import FirebaseFirestore
import Foundation
import SwiftUI

struct MiniEventView: View {
    var eventID: String
    @State private var event: Event = .init()
    @State private var eventView = false
    @State private var selectedTab = 0

    var body: some View {
        Button {
            withAnimation {
                eventView.toggle()
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                if event.bannerURL.isEmpty {
                    ZStack {
                        Rectangle()
                            .fill(LinearGradient(colors: [.accentColor, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: event.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 9, height: UIScreen.main.bounds.width / 9)
                            .foregroundColor(.white)
                    }
                } else {
                    SmallEventBanner(imageURL: URL(string: event.bannerURL))
                }
                Text(event.name)
                    .padding(2)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .frame(width: UIScreen.main.bounds.width / 2.25, height: UIScreen.main.bounds.width / 2.25)
        .background(Color.blue)
        .cornerRadius(10)
        .onAppear {
            fetchEventDetails(for: eventID) { temp in
                event = temp!
            }
        }
        .sheet(isPresented: $eventView) {
            EventDetailsView(event: event, eventView: $eventView)
        }
    }

    func fetchEventDetails(for eventID: String, completion: @escaping (Event?) -> Void) {
        let eventRef = db.collection("Events").document(eventID)

        eventRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let coordinate = data?["Coordinate"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                let event = Event(
                    name: data?["Name"] as? String ?? "",
                    description: data?["Description"] as? String ?? "",
                    host: data?["Host"] as? String ?? "",
                    address: data?["Address"] as? String ?? "",
                    start: (data?["Start"] as? Timestamp)?.dateValue() ?? Date(),
                    end: (data?["End"] as? Timestamp)?.dateValue() ?? Date(),
                    hostUID: data?["HostUID"] as? String ?? "",
                    icon: data?["Icon"] as? String ?? "",
                    coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                    bannerURL: data?["Event Image"] as? String ?? "",
                    hype: data?["Hype"] as? String ?? "low",
                    id: document.documentID
                )
                completion(event)
            } else {
                print("Error fetching event document: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
}
