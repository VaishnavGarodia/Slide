//  MapPage.swift
//  Slide
//  Created by Vaishnav Garodia

import CoreLocation
import MapKit
import SwiftUI

struct MapPage: View {
    
    @Binding var creation: Bool
    @State private var searchText = ""
    @State private var loading = false
    @State private var book = false
    @State private var doc = ""
    @State private var data: Data = .init(count: 0)
    let createEventSearch: Bool = false

    var body: some View {
        ZStack {
            MapView()
                .ignoresSafeArea()

            ZStack {
                VStack {
                    ZStack(alignment: .topLeading) {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    creation.toggle()
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .padding(-5)
                                    .filledBubble()
                                    .frame(width: 60)
                                    .padding(.trailing, 30)
                                    .padding(.top, -15)
                            }
                        }

                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search", text: $searchText)
                                .onChange(of: searchText) { _ in
                                }
                        }
                        .frame(width: 250)
                        .padding(-7.5)
                        .bubbleStyle(color: .primary)
                        .background(RoundedRectangle(cornerRadius: 20).foregroundColor(.black.opacity(0.5)))
                        .padding()
                        .padding(.top, -15)

//                        SearchView(location: self.$destination, detail: self.$show, createEventSearch: self.createEventSearch, frame: 280)
//                            .padding(.top, -15)
                    }
                    Spacer()
                }
            }
        }
//        .alert(isPresented: self.$alert) { () -> Alert in
//            Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
//        }
    }
}

struct MapPage_Previews: PreviewProvider {
    static var previews: some View {
        MapPage(creation: .constant(false))
    }
}
