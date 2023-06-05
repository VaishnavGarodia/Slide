//
//  ListPage.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import SwiftUI
public var numEvents = 10

struct ListPage: View {
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 95)
        
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 75)
                                .padding()
                                .foregroundStyle(.linearGradient(Gradient(colors: [.gray, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image("dj")
                                .resizable()
                                .clipped()
                                .frame(width: 65, height: 65)
                        }
                                    
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.green)
                            .padding()
                            .imageScale(.large)
                    }
        
                    VStack {
                        Text("Nick's Party")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                        HStack {
                            Image(systemName: "mappin")
                                .padding(.leading, 40)
                                .padding(.trailing, -5)
                            Text("Arcade")
                                .padding(.bottom, 2.5)
                        }
                        Text("7:00 PM")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 95)
        
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 75)
                                .padding()
                                .foregroundStyle(.linearGradient(Gradient(colors: [.gray, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image("party")
                                .resizable()
                                .clipped()
                                .frame(width: 65, height: 65)
                                .padding(.top)
                        }
                                    
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.green)
                            .padding()
                            .imageScale(.large)
                    }
        
                    VStack {
                        Text("John's Birthday Party")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                        HStack {
                            Image(systemName: "mappin")
                                .padding(.leading, 40)
                                .padding(.trailing, -5)
                            Text("Dorm")
                                .padding(.bottom, 2.5)
                        }
                        Text("7:00 PM")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 95)
        
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 75)
                                .padding()
                                .foregroundStyle(.linearGradient(Gradient(colors: [.gray, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image("eating")
                                .resizable()
                                .clipped()
                                .frame(width: 65, height: 65)
                        }
                                    
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.green)
                            .padding()
                            .imageScale(.large)
                    }
        
                    VStack {
                        Text("Team Dinner")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                        HStack {
                            Image(systemName: "mappin")
                                .padding(.leading, 40)
                                .padding(.trailing, -5)
                            Text("Olive Garden")
                                .padding(.bottom, 2.5)
                        }
                        Text("8:00 PM")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 95)
        
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 75)
                                .padding()
                                .foregroundStyle(.linearGradient(Gradient(colors: [.gray, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image(systemName: "figure.run")
                                .resizable()
                                .clipped()
                                .frame(width: 40, height: 45)
                        }
                                    
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.green)
                            .padding()
                            .imageScale(.large)
                    }
        
                    VStack {
                        Text("Community 5K")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                        HStack {
                            Image(systemName: "mappin")
                                .padding(.leading, 40)
                                .padding(.trailing, -5)
                            Text("Local Park")
                                .padding(.bottom, 2.5)
                        }
                        Text("7:00 AM Tomorrow")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 95)
    
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 75)
                                .padding()
                                .foregroundStyle(.linearGradient(Gradient(colors: [.gray, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image(systemName: "gamecontroller")
                                .resizable()
                                .clipped()
                                .frame(width: 50, height: 35)
                        }
                                
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.green)
                            .padding()
                            .imageScale(.large)
                    }
    
                    VStack {
                        Text("ESports Event")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                        HStack {
                            Image(systemName: "mappin")
                                .padding(.leading, 40)
                                .padding(.trailing, -5)
                            Text("Dorm")
                                .padding(.bottom, 2.5)
                        }
                        Text("5:00 PM Tomorrow")
                            .padding(.leading, 40)
                            .padding(.bottom, 2.5)
                    }
                }
            }
//            VStack {
//                ForEach(0..<numEvents, id: \.self) {_ in
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 25)
//                            .foregroundStyle(.linearGradient(Gradient(colors: [.accentColor, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
//                            .frame(height: 95)
//
//                        HStack {
//                            Circle()
//                                .frame(width:75)
//                                .padding()
//                            Spacer()
//                            Image(systemName: "checkmark.circle.fill")
//                                .foregroundColor(Color.green)
//                                .padding()
//                                .imageScale(.large)
//                        }
//
//                        VStack {
//                            Text("Event")
//                                .padding(.leading,  40)
//                                .padding(.bottom,  2.5)
//                            Text("Location")
//                                .padding(.leading,  40)
//                                .padding(.bottom,  2.5)
//                            Text("Time")
//                                .padding(.leading,  40)
//                                .padding(.bottom,  2.5)
//                        }
//                    }
//                }
//            }
        }
    }
}

struct ListPage_Previews: PreviewProvider {
    static var previews: some View {
        ListPage()
    }
}
