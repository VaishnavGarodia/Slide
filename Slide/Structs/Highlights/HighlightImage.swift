// HighlightImage.swift
// Slide
// Created by Ethan Harianto on 7/26/23.

import Foundation
import Kingfisher
import SwiftUI
import UIKit

struct HighlightImage: View {
    @State private var height: CGFloat = 600
    var imageURL: URL
    var body: some View {
        GeometryReader { _ in
            KFImage(imageURL)
                .resizable()
                .fade(duration: 0.25)
                .cacheMemoryOnly()
                .onSuccess { imageResult in
                    let aspectRatio = imageResult.image.size.width / imageResult.image.size.height
                    if aspectRatio > 1 {
                        // Landscape image
                        self.height = UIScreen.main.bounds.width / 1.26
                    } else {
                        // Portrait or square image
                        self.height = UIScreen.main.bounds.width / 0.63
                    }
                }
                .scaledToFill()
        }
        .frame(width: UIScreen.main.bounds.width, height: height)
    }
}
