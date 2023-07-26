//  MainView.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import SwiftUI
import UIKit

struct MainView: View {
    init() {
        /* When initialized, the following code changes the tab bar so that unselected items are white and the bar is opaque. */
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
    }
    
    /* The selection variable here defines which tab on the tab view the app initially starts on (the map) */
    @State private var selection = 2
    var body: some View {
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
