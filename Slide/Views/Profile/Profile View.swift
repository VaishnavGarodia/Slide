//
//  Profile View.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import Firebase
import SwiftUI

struct ProfileView: View {
    @State private var recSize = 100.0
    @State private var numEvents = 1
    @State private var numHighlights = 1
    @State private var numSaved = 1
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 120.0, height: 120.0)
                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding()
                
                ProfilePictureView()
            }
            
            Text(user?.displayName ?? "")
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Events")
                        .font(.title2)
                    
                    Image(systemName: "clock.arrow.circlepath")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<numEvents, id: \.self) { _ in
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
                        Image("Event1")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: recSize, height: recSize)
                        
                        Image("Event2")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: recSize, height: recSize)
                        
                        Image("Event3")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: recSize, height: recSize)
                        
                        ForEach(0..<numHighlights, id: \.self) { _ in
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
                        Image("Saved1")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: recSize, height: recSize)
                        
                        Image("Saved2")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: recSize, height: recSize)
                        
                        Image("Saved3")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: recSize, height: recSize)
                        
                        Image("Saved4")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: recSize, height: recSize)
                        
                        Image("Saved5")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: recSize, height: recSize)
                        
                        ForEach(0..<numSaved, id: \.self) { _ in
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
