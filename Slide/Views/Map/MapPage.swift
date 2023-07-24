//
//  MapPage.swift
//  Slide
//
//  Created by Ethan Harianto on 12/23/22.
//

import SwiftUI

struct MapPage: View {
    @State private var searchText = ""
    @State private var showListSheet = false
    @GestureState private var isSwipeUp = false
    
    var body: some View {
        ZStack {
            MapWithEvents()
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
                            NavigationLink(destination: CreatingNewEventView()) {
                                Image(systemName: "plus")
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
        .sheet(isPresented: $showListSheet) {
            ListPage()
        }
        .gesture(
            DragGesture()
                .updating($isSwipeUp) { value, state, _ in
                    state = value.startLocation.y > value.location.y
                }
                .onEnded { value in
                    if value.startLocation.y > value.location.y && value.translation.height > 200 {
                        showListSheet = true
                    }
                }
        )
    }
}




struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage()
    }
}
