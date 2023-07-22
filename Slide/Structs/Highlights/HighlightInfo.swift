//
//  HighlightInfo.swift
//  Slide
//
//  Created by Ethan Harianto on 7/20/23.
//

import Foundation

struct HighlightInfo: Identifiable {
    var id = UUID()
    var imageName: String
    var profileImageName: String
    var username: String
    var highlightTitle: String
}
