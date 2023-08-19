//
//  HighlightInfo.swift
//  Slide
//
//  Created by Ethan Harianto on 7/20/23.
//

import Foundation

struct HighlightInfo: Identifiable, Equatable {
    static func == (lhs: HighlightInfo, rhs: HighlightInfo) -> Bool {
        // Implement the comparison logic here.
        // For example, you could compare based on some unique property like the imageName.
        // Return true if they are equal, and false otherwise.
        return lhs.imageName == rhs.imageName
    }

    var uid: String
    var id = UUID()
    var postID: String
    var imageName: String
    var profileImageName: String
    var username: String
    var highlightTitle: String
    var likedUsers: [String] // List of user document ids that liked the post
}
