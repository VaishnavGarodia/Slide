//
//  LocationSearchView.swift
//  Slide
//
//  Created by Vaishnav Garodia
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var location = ""
    @StateObject var viewModel = LocationSearchViewModel()
    @State private var click = false
    var body: some View {
        ZStack {
            if click {
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                    .ignoresSafeArea()
            }
            
            VStack {
                VStack(alignment: .center) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                            .clipped()
                            .frame(width: 250, height: 40)
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search", text: $viewModel.queryFragment, onEditingChanged: { editingChanged in
                                if editingChanged {
                                    click.toggle()
                                } else {
                                    click.toggle()
                                }
                            })
                        }
                        .padding()
                    }
                    .frame(width: 220)
                }
                
                Divider()
                    .padding(.top, -5)
                
                if click && viewModel.queryFragment != "" {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.results, id: \.self) { result in
                                if result.subtitle != "Search Nearby" {
                                    ZStack {
                                        Button(action: {
                                        viewModel.makeAnnotation(completion: result)
                                            print("button clicked" + result.title)
                                            
                                        }){
                                            HStack {
                                                Image(systemName: "mappin.circle.fill")
                                                    .resizable()
                                                    .foregroundColor(.blue)
                                                    .accentColor(.white)
                                                    .frame(width: 40, height: 40)
                                                
                                                VStack {
                                                    Text(result.title)
                                                        .font(.body)
                                                    
                                                    Text(result.subtitle)
                                                        .font(.system(size: 15))
                                                        .foregroundColor(.gray)
                                                    
                                                    Divider()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                }
            }
        }
    }
}

struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView()
    }
}
