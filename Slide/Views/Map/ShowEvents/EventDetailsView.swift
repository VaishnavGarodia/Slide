//  EventDetailsView.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import SwiftUI

struct EventDetailsView: View {
    var image: UIImage = .init()
    var bannerURL: String
    var icon: String
    var name: String
    var description: String
    var host: String
    var hostName: String
    var start: String
    var end: String
    @State private var isRSVPed = true
    @State private var isLoading = false
    @State private var showDescription = false

    var body: some View {
        VStack {
            // Display event details here based on the 'event' parameter
            // For example:
            HStack {
                Image(systemName: icon)
                    .imageScale(.large)
                Text(name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding()
            Capsule()
                .frame(width: UIScreen.main.bounds.width * 0.85, height: 5)
                .foregroundColor(.primary)
            if !bannerURL.isEmpty {
                EventBanner(imageURL: URL(string: bannerURL)!)
                    .cornerRadius(15)
                    .padding()
            } else if image != UIImage() {
                EventBanner(image: image)
                    .frame(width: UIScreen.main.bounds.width * 0.95)
                    .frame(maxHeight: UIScreen.main.bounds.width * 0.95 * 3 / 4)
                    .cornerRadius(15)
                    .padding()
            }

            Capsule()
                .frame(width: UIScreen.main.bounds.width * 0.85, height: 5)
                .foregroundColor(.primary)

            // ... (display other details as needed)
            Text(hostName)
            HStack {
                Text(start)
                Text("-")
                Text(end)
            }
            // Pass in address
            // Text(address)

            Button {
                withAnimation {
                    showDescription.toggle()
                }
            }
            label: {
                Text(showDescription ? "Hide Description" : "Show Description").font(.caption).foregroundColor(.gray)
            }
            if showDescription {
                Text(description)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    BackgroundComponent()
                    DraggingComponent(isRSVPed: $isRSVPed, isLoading: isLoading, maxWidth: geometry.size.width)
                }
            }
            .frame(height: 50)
            .padding()
            .onChange(of: isRSVPed) { isRSVPed in
                guard !isRSVPed else { return }
                simulateRequest()
            }
        }
        .padding(16)
    }

    private func simulateRequest() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(bannerURL: "https://static01.nyt.com/images/2023/02/13/multimedia/08BEFORE-MIDNIGHT-fzql/08BEFORE-MIDNIGHT-fzql-articleLarge.jpg?quality=75&auto=webp&disable=upscale", icon: "party.popper", name: "Party", description: "Tom's Birthday Party", host: "tomholland", hostName: "Tom Holland", start: "6:30 PM", end: "9:30 PM")
    }
}
