//  EventDetailsView.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import FirebaseFirestore
import SwiftUI

struct EventDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var image: UIImage = .init()
    var event: Event
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isRSVPed = true
    @State private var isLoading = false
    @State private var showDescription = false

    var body: some View {
        VStack {
            HStack {
                Button { self.presentationMode.wrappedValue.dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
                .padding(.leading)
                Spacer()
            }
            // Display event details here based on the 'event' parameter
            // For example:
            HStack {
                Button { self.presentationMode.wrappedValue.dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
                .padding(.leading)
                Spacer()
            }
            HStack {
                Image(systemName: event.icon)
                    .imageScale(.large)
                Text(event.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding()

            Group {
                if !event.bannerURL.isEmpty || image != UIImage() {
                    Capsule()
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                        .foregroundColor(.primary)
                }

                if !event.bannerURL.isEmpty {
                    EventBanner(imageURL: URL(string: event.bannerURL)!)
                        .cornerRadius(15)
                        .padding()
                } else if image != UIImage() {
                    EventBanner(image: image)
                        .frame(width: UIScreen.main.bounds.width * 0.95)
                        .frame(maxHeight: UIScreen.main.bounds.width * 0.95 * 3 / 4)
                        .cornerRadius(15)
                        .padding()
                }
                if !event.bannerURL.isEmpty || image != UIImage() {
                    Capsule()
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                        .foregroundColor(.primary)
                }
            }

            // ... (display other details as needed)
            Text(event.hostName)
            HStack {
                Text(formatDate(date: event.start))
                Text("-")
                Text(formatDate(date: event.end))
            }
            // Pass in address
            HStack {
                Image(systemName: "mappin")
                Text(event.address)
            }
            

            Button {
                withAnimation {
                    showDescription.toggle()
                }
            }
            label: {
                Text(showDescription ? "Hide Description" : "Show Description").font(.caption).foregroundColor(.gray)
            }
            if showDescription {
                Text(event.eventDescription)
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

    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none // You can choose a different style here
        dateFormatter.timeStyle = .short // You can choose a different style here
        return dateFormatter.string(from: date)
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
        EventDetailsView(event: Event())
    }
}
