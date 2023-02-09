//
//  UserListener.swift
//  Slide
//
//  Created by Ethan Harianto on 2/10/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

class UserListener: ObservableObject {
    @Published var user: User?

    init() {
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
        }
    }
}
