//
//  Notification Permission.swift
//  Slide
//
//  Created by Ethan Harianto on 7/21/23.
//

import Foundation
import UserNotifications

class NotificationPermission: NSObject, ObservableObject {
    @Published var isNotificationPermission: Bool = false

    override init() {
        super.init()
        checkNotificationPermission()
    }

    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.handleNotificationPermissionStatus(settings.authorizationStatus)
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.handleNotificationPermissionStatus(granted ? .authorized : .denied)
            }
        }
    }

    private func handleNotificationPermissionStatus(_ status: UNAuthorizationStatus) {
        switch status {
        case .authorized, .provisional:
            isNotificationPermission = true
        case .denied:
            isNotificationPermission = false
        case .notDetermined:
            isNotificationPermission = false
        default:
            isNotificationPermission = false
        }
    }
}

