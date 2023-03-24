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
            
            LocationSearchView()
            
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        
                        ZStack {
                            Circle()
                                .clipped()
                                .frame(width: 35)
                                .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                            NavigationLink(destination:  CreatingNewEventView()) {
                                    Image(systemName: "plus")
                                        .imageScale(.large)
                            }
                            .foregroundColor(.white)
                        }

                        ZStack {
                            Circle()
                                .clipped()
                                .frame(width: 35)
                                .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                            NavigationLink(destination:  ListPage()) {
                                    Image(systemName: "list.dash")
                                        .imageScale(.large)
                            }
                            .foregroundColor(.white)
                        }

                    }
                }
                .padding(.top)
                Spacer()
            }
            .padding()

        }
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
