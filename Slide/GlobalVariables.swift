//
//  GlobalVariables.swift
//  Slide
//
//  Created by Ethan Harianto on 7/12/23.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SwiftUI

let storage = Storage.storage()
let storageRef = storage.reference()
let db = Firestore.firestore()
var hypestEventScore = 0
