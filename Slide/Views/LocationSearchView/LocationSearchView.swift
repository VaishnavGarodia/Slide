//
//  LocationSearchView.swift
//  Slide
//
//  Created by Thomas Shundi on 1/18/23.
//

import SwiftUI

struct LocationSearchView: View {
    @State private var location = ""
    @StateObject var viewModel = LocationSearchViewModel()
    
    
    var body: some View {
        VStack {
            VStack {
                // you could make this a zstack with a rounded rectangle so the shape is more modernized (see map page for example)
                // just a cosmetic thing ofc
                TextField("Event Location", text: $viewModel.queryFragment)
                    .frame(height:30)
                    .background(Color(.systemGray4))
                    .padding(.leading)
                //added this for symmetry because OCD - E
                    .padding(.trailing)
            }.padding(.top, 30)
            
            Divider()
                .padding(.top, -5)
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.results, id: \.self) {result in
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .foregroundColor(.blue)
                                .accentColor(.white)
                                .frame(width:40, height: 40)
                            
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
            
        }.background(.black)
    }
}

struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView()
    }
}
