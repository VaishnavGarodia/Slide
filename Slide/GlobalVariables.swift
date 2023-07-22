//
//  GlobalVariables.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import Foundation
import Firebase
import FirebaseStorage
import MapKit

let storage = Storage.storage()
let storageRef = storage.reference()
let db = Firestore.firestore()
let user = Auth.auth().currentUser

