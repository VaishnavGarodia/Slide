//
//  MapPage.swift
//  Slide
//
//  Created by Ethan Harianto on 12/23/22.
//

import SwiftUI

struct MapPage: View {
    @State private var searchText = ""
    var body: some View {
        ZStack {
            MapOnly()
                .ignoresSafeArea()
            VStack {
                ZStack {
                    HStack {
                         Image(systemName: "magnifyingglass")
                            .padding()
                         TextField("Search", text: $searchText)
                     }
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                }
                .frame(width:220)
                Spacer()
            }
            
        }
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
