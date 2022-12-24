//
//  Profile View.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

struct Profile_View: View {
    @State public var recSize = 100.0
    @State public var numEvents = 1
    @State public var numHighlights = 1
    @State public var numSaved = 1
    
    var body: some View {
        
        VStack {
            ZStack {
                Circle()
                    .frame(width: 150.0, height: 150.0)
                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding()
                
                Image("ProfilePic")
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 140.0, height: 140.0)
            }
            
            Text("TomHolland")
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
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 25)
//                                    .frame(width: recSize, height: recSize, alignment: .leading)
//                                .foregroundColor(.gray)
//
//                                Image(systemName: "plus")
//                            }
                            

                            
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
                        ZStack {
                               
                            Image("Event1")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .frame(width: recSize, height: recSize)
                        }
                        
                        ZStack {
                               
                            Image("Event2")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .frame(width: recSize, height: recSize)
                        }
                        
                        ZStack {
                               
                            Image("Event3")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .frame(width: recSize, height: recSize)
                        }
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
                        ZStack {
                               
                            Image("Saved1")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .frame(width: recSize, height: recSize)
                        }
                        ZStack {
                               
                            Image("Saved2")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .frame(width: recSize, height: recSize)
                        }
                        ZStack {
                               
                            Image("Saved3")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .frame(width: recSize, height: recSize)
                        }
                        ZStack {
                               
                            Image("Saved4")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .frame(width: recSize, height: recSize)
                        }
                        ZStack {
                               
                            Image("Saved5")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .frame(width: recSize, height: recSize)
                        }
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
        .ignoresSafeArea()
    }


}

struct Profile_View_Previews: PreviewProvider {
    static var previews: some View {
        Profile_View()
    }
}
