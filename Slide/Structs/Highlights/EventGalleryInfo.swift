//
//  EventGalleryInfo.swift
//  Slide
//
//  Created by Thomas on 7/27/23.
//

import Foundation


struct EventGalleryInfo: Identifiable {
    var id = UUID()
    var icon: String
    var eventName: String
    var eventID: String
    var postIds: [String] // Document IDs for posts associated with the event
}
