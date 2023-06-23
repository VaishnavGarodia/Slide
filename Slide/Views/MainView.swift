//
//  MainView.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI
import UIKit

struct MainView: View {
    // makes tab bar pretty
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().barTintColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
        UITabBar.appearance().isTranslucent = false
    }

    // selection variable which dictates which tab shows up when mainview is called
    @State private var selection = 2
    var body: some View {
        // tab view means theres a tab bar and the selection makes it so it depends on the variable we called selection
        TabView(selection: $selection) {
            Highlights()
                .tabItem {
                    Label("", systemImage: "light.ribbon")
                }
                .tag(0)
                
            MessagesTab()
                .tabItem {
                    Label("", systemImage: "person.2")
                }
                .tag(1)
                
            MapPage()
                .tabItem {
                    Label("", systemImage: "map")
                }
                .tag(2)
                
            ProfileView()
                .tabItem {
                    Label("", systemImage: "person.circle")
                }
                .tag(3)
                
            SettingsView()
                .tabItem {
                    Label("", systemImage: "gear")
                }
                .tag(4)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
