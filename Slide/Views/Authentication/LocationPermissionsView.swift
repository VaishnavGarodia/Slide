//
//  SwiftUIView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/16/23.
//

import SwiftUI
import CoreLocation

struct LocationPermissionsView: View {
    @ObservedObject var locationPermission = LocationPermission()
    
    var body: some View {
        VStack (alignment: .center) {
            
            Image("location_permission")
                .resizable()
                .frame(width: 160, height: 160)
            
            Text("Allow location access?")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("We need to know where you are in order to display nearby events")
                .frame(width: 300)
                .multilineTextAlignment(.center)
                .padding()
                
            Button("Sounds good!", action: {
                locationPermission.requestLocationPermission()
            })
            .filledBubble()
            .padding()
        }
    }
}


struct LocationPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionsView()
    }
}
