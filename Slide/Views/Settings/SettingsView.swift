//
//  SettingsView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import Firebase
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Button("Sign Out", action: SignOut)
    }

    func SignOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
