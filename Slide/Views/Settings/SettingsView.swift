//
//  SettingsView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import Firebase
import SwiftUI

struct SettingsView: View {
    let username = user?.displayName
    let phoneNumber = user?.phoneNumber
    let email = user?.email
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Username")
                    Spacer()
                    Text(username ?? "")
                }
                HStack {
                    Text("Password")
                    Spacer()
                }
                HStack {
                    Text("Phone Number")
                    Spacer()
                    Text(phoneNumber ?? "")
                }
                HStack {
                    Text("Email")
                    Spacer()
                    Text(email ?? "")
                        .foregroundColor(user?.isEmailVerified ?? false ? .primary : .red)
                }
                Button("Sign Out", action: signOut)
            }
            .padding()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
