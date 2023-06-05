//
//  Profile View.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import Firebase
import SwiftUI

struct Profile_View: View {
    @State public var recSize = 100.0
    @State public var numEvents = 1
    @State public var numHighlights = 1
    @State public var numSaved = 1
    @State public var user = Auth.auth().currentUser
//
//    func downloadpic()  -> Image {
//        var profilePic = Image("")
//        var profilePicRef = storageRef.child("profilePics/" + (user?.uid ?? "default") + ".jpg")
//        profilePicRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//
//          if let error = error {
//            return
//          } else {
//              profilePic =  Image(uiImage: UIImage(data: data) ?? "ProfilePic")
//          }
//        }
//        return profilePic
//    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 120.0, height: 120.0)
                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding()
                
                ProfilePictureView(profilePictureURL: user?.photoURL ?? URL(string: "https://t3.ftcdn.net/jpg/01/65/63/94/360_F_165639425_kRh61s497pV7IOPAjwjme1btB8ICkV0L.jpg"))
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

struct Profile_View_Previews: PreviewProvider {
    static var previews: some View {
        Profile_View()
    }
}
