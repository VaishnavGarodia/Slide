//
//  MiniEventView.swift
//  Slide
//
//  Created by Thomas on 8/15/23.
//

import Foundation
import SwiftUI

// Define MiniEventView here (you need to implement this separately)
struct MiniEventView: View {
    var eventID: String
    
    var body: some View {
        NavigationLink(destination: BigEventView(eventID: eventID)) {
            Text("Mini Event View for Event ID: \(eventID)")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}
