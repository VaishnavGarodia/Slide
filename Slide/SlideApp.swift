//
//  SlideApp.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Firebase

var handle: AuthStateDidChangeListenerHandle?

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
    return true
  }
}

class MainViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { auth, user in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
          Auth.auth().removeStateDidChangeListener(handle!)
        }
}

@main
struct SlideApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene { 
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}

let storage = Storage.storage()
let storageRef = storage.reference()
let db = Firestore.firestore()
