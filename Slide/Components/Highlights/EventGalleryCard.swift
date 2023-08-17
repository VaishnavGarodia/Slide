//  EventGalleryCard.swift
//  Slide
//  Created by Thomas on 7/27/23.

import Foundation
import SwiftUI

struct EventGalleryCard: View {
    var eventGalleryInfo: EventGalleryInfo
    @State private var tempHighlights: [HighlightInfo] = [] // Temporary storage for fetched highlights
    @State private var selectedTab = 0 // Keep track of the selected tab index
    @StateObject private var highlightData = HighlightData() // Use @StateObject to manage data flow
    @Binding var profileView: Bool
    @Binding var selectedUser: UserData?

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Image(systemName: eventGalleryInfo.icon)
                        Text(eventGalleryInfo.eventName)
                            .fontWeight(.bold)
                    }
                    .padding(-5)
                    .bubbleStyle(color: .white)

                    TabView(selection: $selectedTab) {
                        ForEach(tempHighlights.indices, id: \.self) { index in
                            HighlightCard(highlight: tempHighlights[index], selectedUser: $selectedUser, profileView: $profileView)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Use PageTabViewStyle for the carousel effect
                    .aspectRatio(0.63, contentMode: .fit)
                    .onChange(of: tempHighlights) { newHighlights in
                        highlightData.highlights = newHighlights // Update the @StateObject with the fetched highlights
                    }
                    .onAppear {
                        // Fetch highlight info when the view appears
                        fetchHighlights()
                    }
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.width / 0.63
                    )
                }
            }
            .edgesIgnoringSafeArea(.all)

            CustomSegmentedView(totalTabs: tempHighlights.count, selectedTab: $selectedTab)
                .padding(.bottom)
        }
    }

    private func fetchHighlights() {
        let dispatchGroup = DispatchGroup()

        for postId in eventGalleryInfo.postIds {
            dispatchGroup.enter()
            getHighlightInfo(highlightID: postId) { highlightInfo in
                if let highlightInfo = highlightInfo {
                    tempHighlights.append(highlightInfo)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            // All async calls are completed, the @onChange will be called to update highlightData
        }
    }
}

class HighlightData: ObservableObject {
    @Published var highlights: [HighlightInfo] = []
    @Published var selectedTab = 0
}
