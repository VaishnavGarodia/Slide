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
                        self.height = UIScreen.main.bounds.width * 0.95 * 3 / 4
                    } else {
                        // Portrait or square image
                        self.height = UIScreen.main.bounds.width * 0.95 * 4 / 3
                    }
                }
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width * 0.95, height: height)
        } else {
            GeometryReader { _ in
                Image(uiImage: image!)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}
