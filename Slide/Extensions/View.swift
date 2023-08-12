//
//  View.swift
//  Slide
//
//  Created by Ethan Harianto on 7/14/23.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    func bubbleStyle(color: Color) -> some View {
        modifier(BubbledTextField(color: color))
    }
    func filledBubble() -> some View {
        modifier(FilledBubble())
    }
    func emptyBubble() -> some View {
        modifier(EmptyBubble())
    }
    func checkMarkTextField() -> some View {
        self.modifier(CheckMarkTextField())
    }
    
    func underlineGradient() -> some View {
        self.modifier(UnderlinedGradient())
    }

    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }

        return root
    }
    
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
 // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

struct BubbledTextField: ViewModifier {
    @FocusState private var isFocused: Bool
    let color: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(isFocused ? Color.accentColor : color)
            )
            .animation(.linear, value: isFocused)
            .focused($isFocused)
    }
}

struct FilledBubble: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Color.accentColor
            )
            .foregroundColor(.white)
            .fontWeight(.bold)
            .cornerRadius(15)
            .padding(.top)
    }
}

struct UnderlinedGradient: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .leading, endPoint: .trailing)
                .frame(height: 4)
                .clipShape(Capsule())
            
            content
                .foregroundColor(.primary)
                .fontWeight(.bold)
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.clear)
    }
}


struct EmptyBubble: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.clear, lineWidth: 2)
            )
            .foregroundColor(.gray)
            .font(.system(size: 16, weight: .bold))
    }
}

struct CheckMarkTextField: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
                .focused($isFocused)
                .onTapGesture {
                    isFocused = true
                }

            if isFocused {
                Button(action: {
                    isFocused = false
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cyan)
                        .font(.title2)
                }
                .animation(.easeIn, value: isFocused)
            }
        }
        
    }
}
