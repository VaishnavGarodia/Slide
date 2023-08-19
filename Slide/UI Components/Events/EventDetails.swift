//  EventDetails.swift
//  Slide
//  Created by Vaishnav Garodia on 8/8/23.

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct EventDetails: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var image: UIImage = .init()
    var event: Event
    var preview = false
    @Binding var eventView: Bool
    @State var fromMap: Bool = false
    @State private var isRSVPed = true
    @State private var isLoading = false
    @State private var showDescription = false

    var body: some View {
        VStack(alignment: .center) {
            // Display event details here based on the 'event' parameter
            // For example:
            HStack {
                if !fromMap {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(.leading)
                    }

                } else {
                    Button {
                        withAnimation {
                            eventView.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(.leading)
                    }
                }
                Spacer()
                if !event.bannerURL.isEmpty && image != UIImage() {
                    Image(systemName: event.icon)
                        .imageScale(.large)
                }

                Text(event.name)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()

            Group {
                Capsule()
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                    .foregroundColor(.primary)

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
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(colors: [.accentColor, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.95 * 3 / 4)
                        Image(systemName: event.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
                    }
                }

                Capsule()
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: 3)
                    .foregroundColor(.primary)
            }

            // ... (display other details as needed)
            Text(event.host)
            HStack {
                Text(formatDate(date: event.start))
                Text("-")
                Text(formatDate(date: event.end))
            }
            HStack {
                Image(systemName: "mappin")
                Text(event.address)
                    .multilineTextAlignment(.center)
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

            if event.hostUID != Auth.auth().currentUser!.uid && !preview {
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
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }

    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short // You can choose a different style here
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
