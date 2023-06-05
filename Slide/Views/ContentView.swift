//
//  ContentView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/16/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userListener = UserListener()

    var body: some View {
        if userListener.user != nil {
            MainView()
        } else {
            LogIn()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
