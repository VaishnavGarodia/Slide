//
//  Profile View.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

struct Profile_View: View {
    @State public var recSize = 100.0
    @State public var numEvents = 20
    @State public var numHighlights = 20
    @State public var numSaved = 20
    
    var body: some View {
        
        VStack {
            ZStack {
                Circle()
                    .frame(width: 125.0, height: 125.0)
                    .foregroundColor(.accentColor)
                    .padding()
                
                Image("ProfilePic")
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 115.0, height: 115.0)
            }
            
            Text("hanzy919")
                .padding(-20.0)
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("Events")
                        .font(.title2)
                    
                    Image(systemName: "clock.arrow.circlepath")
                        
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                ScrollView(.horizontal){
                    HStack {
                        ForEach(0..<numEvents, id: \.self) {_ in
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: recSize, height: recSize, alignment: .leading)
                                .foregroundColor(.gray)
                                
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                
                
                HStack {
                    Text("Highlights")
                        .font(.title2)
                        
                    Image(systemName: "light.ribbon")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<numHighlights, id:\.self) {_ in
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: recSize, height: recSize, alignment: .leading)
                                .foregroundColor(.gray)
                                
                                Image(systemName: "plus")
                            }
                        }
                        
                    }
                }
                
                HStack {
                    Text("Saved")
                        .font(.title2)
                    
                    Image(systemName: "bookmark")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<numSaved, id:\.self) {_ in
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: recSize, height: recSize, alignment: .leading)
                                .foregroundColor(.gray)
                                
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct Profile_View_Previews: PreviewProvider {
    static var previews: some View {
        Profile_View()
    }
}
