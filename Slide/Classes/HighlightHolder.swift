//
//  HighlightHolder.swift
//  Slide
//
//  Created by Ethan Harianto on 7/26/23.
//

import Foundation
import FirebaseFirestore

class HighlightHolder: ObservableObject {
    @Published var highlights: [HighlightInfo] = []
    @Published var friendsCount: Int = 0
    @Published var lastSnapshot: DocumentSnapshot?
}
