//  MainView.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import SwiftUI
import AnimatedTabBar

struct MainView: View {
    @State private var selectedColorScheme: String = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "dark"
    
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

            SettingsView(selectedColorScheme: $selectedColorScheme)
                .tabItem {
                    Label("", systemImage: "gear")
                }
                .tag(4)
        }
        .onAppear {
            UITabBar.customizeAppearance()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
