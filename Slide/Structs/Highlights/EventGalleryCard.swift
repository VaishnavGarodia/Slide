//
//  EventGalleryCard.swift
//  Slide
//
//  Created by Thomas on 7/27/23.
//

import Foundation
import SwiftUI

struct EventGalleryCard: View {
    var eventGalleryInfo: EventGalleryInfo
    @State private var tempHighlights: [HighlightInfo] = [] // Temporary storage for fetched highlights
    @State private var selectedTab = 0 // Keep track of the selected tab index
    @StateObject private var highlightData = HighlightData() // Use @StateObject to manage data flow

    var body: some View {
        VStack(spacing: 16) {
            Text(eventGalleryInfo.eventName)
                .font(.title)
                .fontWeight(.bold)

            if tempHighlights.isEmpty {
                ProgressView() // Show a loading indicator while fetching data
            } else {
                TabView(selection: $selectedTab) {
                    ForEach(tempHighlights.indices, id: \.self) { index in
                        HighlightCard(highlight: tempHighlights[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle()) // Use PageTabViewStyle for the carousel effect
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // Show page indicators
                .aspectRatio(1.5, contentMode: .fit)
                .padding(.horizontal, 16)
                .onChange(of: tempHighlights) { newHighlights in
                    highlightData.highlights = newHighlights // Update the @StateObject with the fetched highlights
                }
            }
        }
        .onAppear {
            // Fetch highlight info when the view appears
            fetchHighlights()
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
