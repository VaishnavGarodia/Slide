//  UserData.swift
//  Slide
//  Created by Ethan Harianto on 7/30/23.

import Foundation
import SwiftUI

struct UserData: Codable, Hashable {
    static func ==(lhs: UserData, rhs: UserData) -> Bool {
        return lhs.userID == rhs.userID
    }
    
    let userID: String
    let username: String
    let photoURL: String
    var added: Bool? = false
}
