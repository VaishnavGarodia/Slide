//
//  GroupsTab.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

struct GroupsTab: View {
    @State public var numGroups = 20
    var body: some View {
        VStack {
            HStack {
                Text("Groups")
                    .foregroundColor(.accentColor)
                    .padding()
                
                NavigationLink {
                    PeopleTab()
                } label: {
                    Label("People", systemImage: "")
                }
                .foregroundColor(Color("OppositeColor"))
                .padding()
                
            }
            
            ScrollView {
                VStack {
                    ForEach(0..<numGroups, id: \.self) {_ in
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                .foregroundColor(.accentColor)
                                
                                Image(systemName: "map")
                            }
                            Text("Group")
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

struct GroupsTab_Previews: PreviewProvider {
    static var previews: some View {
        GroupsTab()
    }
}
