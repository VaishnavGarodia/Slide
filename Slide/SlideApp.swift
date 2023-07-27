//
//  SlideApp.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import Firebase
import GoogleSignIn
import SwiftUI

var handle: AuthStateDidChangeListenerHandle?

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()

        return true
    }
}

@main
struct SlideApp: App {
    @AppStorage("colorSchemePreference") var colorSchemePreference: String = "dark"
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .preferredColorScheme(getColorScheme())
            }
        }
    }

    func getColorScheme() -> ColorScheme {
        switch colorSchemePreference {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return .dark
        }
    }
}
