//
//  SettingsView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import FirebaseAuth
import SwiftUI
import UIKit

struct SettingsView: View {
    @State private var clicks = [false, false, false, false, false, false]
    @Binding var selectedColorScheme: String
    let user = Auth.auth().currentUser
    @State private var updatedUsername: String = ""
    
    var body: some View {
        List {
            // Username
            Button {
                withAnimation {
                    toggleClicks(count: 0)
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Username")
                            .foregroundColor(.primary)
                        Text(user?.displayName ?? "SimUser")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(clicks[0] ? 90 : 0))
                }
            }
                
            if clicks[0] {
                updateUsernameView(updatedUsername: $updatedUsername, clicked: $clicks[0])
            }
                    
            // Email
            Button {
                withAnimation {
                    toggleClicks(count: 1)
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Email")
                            .foregroundColor(.primary)
                        Text(user?.email ?? "SimUser@stanford.edu")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if !(user?.isEmailVerified ?? false) {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                    }
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(clicks[1] ? 90 : 0))
                }
            }
            
            if clicks[1] {
                
            }
                
            // Phone Number
//            Button {
//                withAnimation {
//                    toggleClicks(count: 2)
//                }
//            } label: {
//                HStack {
//                    VStack {
//                        Text("Phone Number")
//                            .foregroundColor(.primary)
//                        if !(user?.phoneNumber ?? "").isEmpty {
//                            Text(user?.phoneNumber ?? "")
//                        }
//                    }
//                    Spacer()
//                    if (user?.phoneNumber ?? "").isEmpty {
//                        Image(systemName: "exclamationmark.circle")
//                            .foregroundColor(.red)
//                    }
//                    Image(systemName: "chevron.right")
//                        .rotationEffect(.degrees(clicks[2] ? 90 : 0))
//                }
//            }
                
            // Password
            Button {
                withAnimation {
                    toggleClicks(count: 3)
                }
            } label: {
                HStack {
                    Text("Password")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(clicks[3] ? 90 : 0))
                }
            }
            
            if clicks[3] {
                
            }
                
            // App Appearance
            Button {
                withAnimation {
                    toggleClicks(count: 4)
                }
            } label: {
                HStack {
                    Text("App Appearance")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(clicks[4] ? 90 : 0))
                }
            }
                
            
            if clicks[4] {
                AppAppearanceView(selectedColorScheme: $selectedColorScheme)
            }
            
            // Sign Out
            Button {
                withAnimation {
                    toggleClicks(count: 5)
                }
            } label: {
                HStack {
                    Text("Sign Out")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(clicks[5] ? 90 : 0))
                }
            }
                
            if clicks[5] {
                SignOutView()
            }
        }
        .onChange(of: selectedColorScheme) { value in
            UserDefaults.standard.set(value, forKey: "colorSchemePreference")
        }
        .onAppear {
            selectedColorScheme = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "dark"
        }
    }
    
    func toggleClicks(count: Int) {
        for index in 0 ..< clicks.count {
            if index != count {
                clicks[index] = false
            }
        }
        clicks[count].toggle()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(selectedColorScheme: .constant("dark"))
    }
}
