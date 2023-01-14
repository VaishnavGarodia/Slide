//
//  EventSearchHomeView.swift
//  Slide
//
//  Created by Thomas Shundi on 1/18/23.
//

import SwiftUI

struct EventSearchHomeView: View {
    var body: some View {
        ZStack(alignment: .top) {
            // would it be possible to use the map page for this?
            EventLocationRepresentable()
                .ignoresSafeArea()
            
            LocationSearchActivationView().padding(.top, 30)
        }
    }
}

struct EventSearchHomeView_Previews: PreviewProvider {
    static var previews: some View {
        EventSearchHomeView()
    }
}
