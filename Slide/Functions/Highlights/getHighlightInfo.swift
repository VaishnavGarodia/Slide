//
//  getHighlightInfo.swift
//  Slide
//
//  Created by Thomas on 7/27/23.
//

import Foundation
import Firebase
import FirebaseFirestore

func getHighlightInfo(highlightID: String, completion: @escaping (HighlightInfo?) -> Void) {
    let db = Firestore.firestore()
    let postsCollectionRef = db.collection("Posts").document(highlightID)
    
    postsCollectionRef.getDocument { document, _ in
        if let document = document, document.exists {
            if let caption = document.data()?["ImageCaption"] as? String,
               let userDocumentID = document.data()?["User"] as? String,
               let imagePath = document.data()?["PostImage"] as? String {
                
                let userCollectionRef = db.collection("Users").document(userDocumentID)
                userCollectionRef.getDocument { document, _ in
                    if let document = document, document.exists {
                        if let username = document.data()?["Username"] as? String {
                            let highlightInfo = HighlightInfo(imageName: imagePath, profileImageName: "ProfilePic2", username: username, highlightTitle: caption)
                            completion(highlightInfo) // Call the completion handler with the result
                        } else {
                            completion(nil) // Call the completion handler with nil if username is not available
                        }
                    } else {
                        completion(nil) // Call the completion handler with nil if the user document doesn't exist or there was an error
                    }
                }
            } else {
                completion(nil) // Call the completion handler with nil if any of the required data is not available
            }
        } else {
            completion(nil) // Call the completion handler with nil if the document doesn't exist or there was an error
        }
    }
}
