//
//  PeopleTab.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI

struct PeopleTab: View {
    @State private var numPeople = 20
    var body: some View {
        VStack {
            HStack {
                NavigationLink {
                    GroupsTab()
                } label: {
                    Label("Groups", systemImage: "")
                }
                .foregroundColor(Color("OppositeColor"))
                .padding()
                
                Text("People")
                    .foregroundColor(.accentColor)
                    .padding()
                
            }
            
            ScrollView {
                VStack {
                    ForEach(0..<numPeople, id: \.self) {_ in
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .padding()
                                .foregroundColor(.accentColor)
                                
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

struct PeopleTab_Previews: PreviewProvider {
    static var previews: some View {
        PeopleTab()
    }
}
