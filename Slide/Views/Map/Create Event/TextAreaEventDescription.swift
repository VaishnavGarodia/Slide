//
//  TextAreaEventDescription.swift
//  Slide
//
//  Created by Thomas Shundi on 2/19/23.
//

import SwiftUI

struct TextAreaEventDescription: View {
    @Binding var text: String
    let placeholder: String

    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.systemGray))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
            }

            TextEditor(text: $text)
                .padding(4)
        }
        .font(.body)
    }
}
