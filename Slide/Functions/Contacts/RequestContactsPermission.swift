//
//  RequestContactsPermission.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import Foundation
import Contacts

func requestContactsPermission() -> Bool {
    let store = CNContactStore()
    var allowed = true
    store.requestAccess(for: .contacts) { granted, _ in
        if granted {
            print("Contacts access granted")
            allowed = true
        } else {
            print("Contacts access denied")
            allowed = false
        }
    }
    return allowed
}
