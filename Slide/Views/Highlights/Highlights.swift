//
//  Highlights.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

struct Highlights: View {
    @State public var numHighlights = 20
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<numHighlights, id: \.self) {_ in
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 350, height: 400)
                        .foregroundColor(.accentColor)
                        .padding()
                }
            }
        }
    }
}

struct Highlights_Previews: PreviewProvider {
    static var previews: some View {
        Highlights()
    }
}
