//  MainView.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import SwiftUI
//import AnimatedTabBar

struct MainView: View {
    @State private var selectedColorScheme: String = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "dark"

    /* The selection variable here defines which tab on the tab view the app initially starts on (the map) */
    @State private var selection = 2
    @State private var isPresentingPostCreationView = false
    @State private var source: UIImagePickerController.SourceType = .camera

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                Highlights(source: $source, isPresentingPostCreationView: $isPresentingPostCreationView)
                    .tag(0)

                MessagesTab()
                    .tag(1)

                MapPage()
                    .tag(2)

                ProfileView()
                    .tag(3)

                NavigationView {
                    SettingsView(selectedColorScheme: $selectedColorScheme)
                        .navigationTitle("Settings")
                }
                .tag(4)
                .navigationViewStyle(.stack)
            }

            HStack {
                if selection == 0 {
                    Menu {
                        Button {
                            withAnimation {
                                source = .camera
                                isPresentingPostCreationView = true
                            }
                        } label: {
                            Label("Post with Camera", systemImage: "camera")
                        }
                        Button {
                            withAnimation {
                                source = .photoLibrary
                                isPresentingPostCreationView = true
                            }
                        } label: {
                            Label("Post from Library", systemImage: "photo")
                        }
                    } label: {
                        Image(systemName: "plus.app")
                            .foregroundColor(.primary)
                            .imageScale(.large)
                            .padding(7.5)
                            .background(Color.accentColor.clipShape(Circle()))
                            .padding()
                    }
                } else {
                    Image(systemName: "light.ribbon")
                        .tabBarItem(index: 0, selection: $selection)
                }

                Image(systemName: "person.2")
                    .tabBarItem(index: 1, selection: $selection)

                Image(systemName: "map")
                    .tabBarItem(index: 2, selection: $selection)

                Image(systemName: "person.circle")
                    .tabBarItem(index: 3, selection: $selection)

                Image(systemName: "gear")
                    .tabBarItem(index: 4, selection: $selection)
            }
            .frame(width: UIScreen.main.bounds.width, height: 55)
            .background(selectedColorScheme == "dark" ? Color.black : Color.white)
            .ignoresSafeArea()
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
