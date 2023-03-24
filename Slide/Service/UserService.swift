//
//  UserService.swift
//  Slide
//
//  Created by Thomas Shundi on 2/19/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserService {
    
    func fetchUser(withUid uid: String) {
        Firestore.firestore().collection("users")
            .document(uid)
            .getDocument() {document,  error in
                guard let document = document else { return }
                
                guard let userU = try? document.data(as: UserT.self) else { return }
                
                print("DEBUG: Username is \(userU.username)")
                print("DEBUG: Email is \(userU.email)")
            }
    }
}
