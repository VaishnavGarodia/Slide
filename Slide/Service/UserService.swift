//
//  UserService.swift
//  Slide
//
//  Created by Thomas Shundi on 2/19/23.
//

import Firebase

struct UserService {
    
    func fetchUser(withUid uid: String) {
        Firestore.firestore().collection("users")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let data = snapshot?.data() else { return }
                
                guard let userT = try? snapshot.data(as: UserT.self) else { return }
                
                print("DEBUG: Username is \(userT.username)")
                print("DEBUG: Email is \(userT.email)")
            }
    }
}
