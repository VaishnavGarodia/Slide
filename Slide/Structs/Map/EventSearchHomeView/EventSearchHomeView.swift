//
//  EventSearchHomeView.swift
//  Slide
//
//  Created by Thomas Shundi on 1/18/23.
//

import SwiftUI

struct EventSearchHomeView: View {
    @State private var showLocationSearchView = false
    var body: some View {
        ZStack(alignment: .top) {
            MapOnly()
                .ignoresSafeArea()
            //LocationSearchView()
//            if showLocationSearchView {
//                LocationSearchView()
//            }
//            else {
//                LocationSearchActivationView()
//                    .padding(.top, 30)
//                    .onTapGesture {
//                        showLocationSearchView.toggle()
//                    }
//            }
        }
    }
}

struct EventSearchHomeView_Previews: PreviewProvider {
    static var previews: some View {
        EventSearchHomeView()
    }
}
