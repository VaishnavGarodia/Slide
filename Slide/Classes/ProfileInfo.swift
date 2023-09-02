//
//  HighlightHolder.swift
//  Slide
//
//  Created by Ethan Harianto on 7/26/23.
//

import Foundation
import FirebaseFirestore

class ProfileInfo: ObservableObject {
    @Published var highlights: [HighlightInfo] = []
    @Published var friendsCount: Int = 0
    @Published var lastSnapshot: DocumentSnapshot?
}

class HighlightObject: ObservableObject {
    @Published var highlights: [HighlightInfo] = []
    @Published var lastSnapshot: DocumentSnapshot?
    @Published var galleries: [Event] = []
}
