//
//  UserData.swift
//  Slide
//
//  Created by Ethan Harianto on 7/30/23.
//

import Foundation
import SwiftUI

struct UserData: Codable {
    let userID: String
    let username: String
    let photoURL: String
    let added: Bool
}
