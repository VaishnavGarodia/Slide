//  MainView.swift
//  Slide
//  Created by Ethan Harianto on 12/21/22.

import SwiftUI

struct MainView: View {
    @State private var selectedColorScheme: String = UserDefaults.standard.string(forKey: "colorSchemePreference") ?? "dark"

    /* The selection variable here defines which tab on the tab view the app initially starts on (the map) */
    @State private var selection = 2
    @State private var isPresentingPostCreationView = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                Highlights(isPresentingPostCreationView: $isPresentingPostCreationView)
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
                Image(systemName: selection == 0 ? "plus.app" : "light.ribbon")
                    .imageScale(selection == 0 ? .large : .medium)
                    .padding(7.5)
                    .background(selection == 0 ? Color.accentColor.clipShape(Circle()) : Color.clear.clipShape(Circle()))
                    .padding()
                    .onTapGesture {
                        selection == 0 ?
                            withAnimation {
                                isPresentingPostCreationView = true
                            } : withAnimation {
                                selection = 0
                            }
                    }
                Image(systemName: "person.2")
                    .imageScale(selection == 1 ? .large : .medium)
                    .padding(7.5)
                    .background(selection == 1 ? Color.accentColor.clipShape(Circle()) : Color.clear.clipShape(Circle()))
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            selection = 1
                        }
                    }
                Image(systemName: "map")
                    .imageScale(selection == 2 ? .large : .medium)
                    .padding(7.5)
                    .background(selection == 2 ? Color.accentColor.clipShape(Circle()) : Color.clear.clipShape(Circle()))
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            selection = 2
                        }
                    }
                Image(systemName: "person.circle")
                    .imageScale(selection == 3 ? .large : .medium)
                    .padding(7.5)
                    .background(selection == 3 ? Color.accentColor.clipShape(Circle()) : Color.clear.clipShape(Circle()))
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            selection = 3
                        }
                    }
                Image(systemName: "gear")
                    .imageScale(selection == 4 ? .large : .medium)
                    .padding(7.5)
                    .background(selection == 4 ? Color.accentColor.clipShape(Circle()) : Color.clear.clipShape(Circle()))
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            selection = 4
                        }
                    }
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
