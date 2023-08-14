//  EventBanner.swift
//  Slide
//  Created by Ethan Harianto on 8/11/23.

import Foundation
import Kingfisher
import SwiftUI

struct EventBanner: View {
    @State private var height: CGFloat = 600
    var imageURL: URL? = nil
    var image: UIImage? = nil
    var body: some View {
        if imageURL != nil {
            KFImage(imageURL)
                .resizable()
                .fade(duration: 0.25)
                .cacheMemoryOnly()
                .onSuccess { imageResult in
                    let aspectRatio = imageResult.image.size.width / imageResult.image.size.height
                    if aspectRatio > 1 {
                        // Landscape image
                        self.height = 4 * UIScreen.main.bounds.width / 7.5
                    } else {
                        // Portrait or square image
                        self.height = 16 * UIScreen.main.bounds.width / 22.5
                    }
                }
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width / 2.5, height: height)
        } else {
            GeometryReader { geometry in
                Image(uiImage: image!)
                    .resizable()
                    .scaledToFill()
                    
            }
        }
    }
}
