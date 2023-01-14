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
                    ZStack {
                                                
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 400, height: 500)
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2 ))
                            
                        Rectangle()
                            .frame(width: 400, height: 400)
                            .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        
                        VStack {
                            HStack {
                                    
                                    Image("ProfilePic")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 35, height: 35)
                                    .padding(7.5)
                                
                                Text("TomHolland")
                                
                                Spacer()

                            }
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "bubble.left")
                                    .imageScale(.medium)
                                .padding()
                                Image(systemName: "bookmark")
                                    .imageScale(.medium)
                                .padding()
                            }
                        }
                        
                    }
                    .padding(75)
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
