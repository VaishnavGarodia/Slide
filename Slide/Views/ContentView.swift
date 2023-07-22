//
//  ContentView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userListener = UserListener()
    @StateObject private var cameraPermission = CameraPermission()
    @StateObject private var locationPermission = LocationPermission()
    @StateObject private var contactsPermission = ContactsPermission()
    @StateObject private var notificationsPermission = NotificationPermission()

    var body: some View {
        if userListener.user != nil {
            switch locationPermission.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                if contactsPermission.isContactsPermission {
                    if cameraPermission.isCameraPermission {
                        MainView()
                    } else {
                        CameraPermissionsView(cameraPermission: cameraPermission)
                    }
                } else {
                    ContactsPermissionsView(contactsPermission: contactsPermission)
                }
                    
                default:
                    LocationPermissionsView(locationPermission: locationPermission)
            }
        } else {
            LogIn()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
