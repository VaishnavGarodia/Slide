//
//  SettingsView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import FirebaseAuth
import SwiftUI

struct SettingsView: View {
    @State private var selectedColorScheme: String = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "dark"

    let phoneNumber = user?.phoneNumber
    let email = user?.email

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Username")
                    Spacer()
                    Text(user?.displayName ?? "")
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

                // Color Scheme Picker
                Picker("Color Scheme", selection: $selectedColorScheme) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button("Sign Out", action: signOut)
                Spacer()
            }
            .padding()
        }
        .onChange(of: selectedColorScheme) { value in
            UserDefaults.standard.set(value, forKey: "colorSchemePreference")
        }
        .onAppear {
            selectedColorScheme = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "system"
        }
    }
    func signOut() {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            print("signed out")
        } catch let signOutError as NSError {
            print("Error signing out: %@" + signOutError.localizedDescription)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
