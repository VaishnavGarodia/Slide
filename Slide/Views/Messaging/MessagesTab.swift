//
//  GroupsTab.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

struct MessagesTab: View {
    @State public var numGroups = 1
    @State public var searchMessages = ""
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "list.bullet")
                    .padding()
                    .imageScale(.large)
                Spacer()
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchMessages)
                }
                .padding()
                Spacer()
                NavigationLink(destination: UserSearchAndFriendView()) {
                    Image(systemName: "person.badge.plus")
                        .padding()
                        .imageScale(.large)
                }
            }
            .padding(.bottom, -10)
            .padding(.top, -10)
            
            ScrollView {
                VStack {
                    ForEach(0 ..< numGroups, id: \.self) { _ in
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image("Group Pic")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50)
                            }
                            Text("Avengers")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("1m •")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image("ProfilePic2")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50)
                            }
                            Text("Zendaya")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("3m •")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image("ProfilePic3")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50)
                            }
                            Text("Robert Downey Jr.")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("15m")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image("profilepic4")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50)
                            }
                            Text("Chris Evans")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("35m")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image("profilepic5")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50)
                            }
                            Text("Andrew Garfield")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("1h •")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image("profilepic6")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50)
                            }
                            Text("Tobey Maguire")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("2h")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image(systemName: "person")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 30, height: 30)
                            }
                            Text("Fan")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("7h")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image(systemName: "person")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 30, height: 30)
                            }
                            Text("Fan")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("1h")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image(systemName: "person")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 30, height: 30)
                            }
                            Text("Fan")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("1h")
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

struct MessagesTab_Previews: PreviewProvider {
    static var previews: some View {
        MessagesTab()
    }
}
