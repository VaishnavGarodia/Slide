//
//  HighlightImage.swift
//  Slide
//
//  Created by Ethan Harianto on 7/26/23.
//

import Foundation
import SwiftUI
import UIKit

struct HighlightImage: View {
    @State private var height: CGFloat = 600
    var uiImage: UIImage

    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .onAppear {
                    let aspectRatio = uiImage.size.width / uiImage.size.height
                    if aspectRatio > 1 {
                        // Landscape image
                        self.height = 300
                    } else {
                        // Portrait or square image
                        self.height = 600
                    }
                }
                
        }
        .frame(width: 380, height: height)
    }
}

