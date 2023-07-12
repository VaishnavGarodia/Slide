//
//  AddContacts.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import Foundation
import Firebase
import FirebaseAuth

func addContact(contact: ContactInfo, username: String) {
    let contactRef = db.collection("Contacts").document(username + "-" + contact.id.uuidString)
    contactRef.getDocument { document, _ in
        if let document = document, document.exists {
            print("oops")
        } else {
            contactRef.setData([
                "ContactUsername": username,
                "firstName": contact.firstName,
                "id": contact.id.uuidString,
                "lastName": contact.lastName,
                "phoneNumber": contact.phoneNumber?.stringValue
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document successfully written.")
                }
            }
        }
    }
}

func addAllContacts(contactList: [ContactInfo]) {
    print("Started saving contacts")
    for contact in contactList {
        addContact(contact: contact, username: Auth.auth().currentUser?.displayName ?? "")
    }
}
