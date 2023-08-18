//  HighlightImageMini.swift
//  Slide
//  Created by Thomas on 8/16/23.

import Foundation
import Kingfisher
import SwiftUI
import UIKit

struct HighlightImageMini: View {
    @State private var height: CGFloat = 0
    
    var imageURL: URL
    
    var body: some View {
        KFImage(imageURL)
            .resizable()
            .fade(duration: 0.25)
            .cacheMemoryOnly()
            .onSuccess { imageResult in
                let aspectRatio = imageResult.image.size.width / imageResult.image.size.height
                if aspectRatio > 1 {
                    // Landscape image
                    self.height = UIScreen.main.bounds.width / 3.5 // Half the width of the phone
                } else {
                    // Portrait or square image
                    self.height = UIScreen.main.bounds.width / 1.75 // A bit more than the width
                }
            }
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width / 2.25, height: height)
            .cornerRadius(10)
    }
}
