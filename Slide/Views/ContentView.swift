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
                case .notDetermined:
                    LocationPermissionsView(locationPermission: locationPermission)

                default:
                    if contactsPermission.checkContactsPermission() == .notDetermined {
                        ContactsPermissionsView(contactsPermission: contactsPermission)
                    } else {
                        if cameraPermission.checkCameraPermission() == .notDetermined {
                            CameraPermissionsView(cameraPermission: cameraPermission)
                        } else {
                            if notificationsPermission.checkNotificationPermission() == .notDetermined {
                                NotificationPermissionsView(notificationsPermission: notificationsPermission)

                            } else {
                                MainView()
                            }
                        }
                    }
            }
        } else {
            AccountCreationView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
