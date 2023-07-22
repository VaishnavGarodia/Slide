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
    func checkMarkTextField() -> some View {
        self.modifier(CheckMarkTextField())
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
}

struct BubbledTextField: ViewModifier {
    @FocusState private var isFocused: Bool
    let color: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(isFocused ? LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [color]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
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
                LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(.white)
            .fontWeight(.bold)
            .cornerRadius(15)
            .padding(.top)
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
