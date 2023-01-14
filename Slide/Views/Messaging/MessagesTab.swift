//
//  GroupsTab.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

struct MessagesTab: View {
    @State public var numGroups = 5
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
                Image(systemName: "person.badge.plus")
                    .padding()
                    .imageScale(.large)
            }
            .padding(.bottom, -10)
            .padding(.top, -10)
            
            ScrollView {
                VStack {
                    ForEach(0..<numGroups, id: \.self) {_ in
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image(systemName: "map")
                            }
                            Text("Group")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("1m")
                                .padding()
                        }
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                
                                Image(systemName: "person")
                            }
                            Text("Person")
                                .padding(.leading, -10.0)
                            Spacer()
                                
                            Text("1m")
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
