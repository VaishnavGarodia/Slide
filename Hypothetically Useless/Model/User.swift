//
//  User.swift
//  Slide
//
//  Created by Thomas Shundi on 2/19/23.
//

// Please figure out how to import this
import FirebaseFirestoreSwift
import SwiftUI

struct UserT: Identifiable, Decodable {
    @DocumentID var id: String?
    let username: String
    let email: String
}
