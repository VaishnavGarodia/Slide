//
//  CameraPermissionsView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/21/23.
//

import SwiftUI

struct CameraPermissionsView: View {
    @ObservedObject var cameraPermission = CameraPermission()
    
    var body: some View {
        VStack (alignment: .center) {
            
            Image("location_permission")
                .resizable()
                .frame(width: 160, height: 160)
            
            Text("Allow camera access?")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("We need to know where you are in order to display nearby events")
                .frame(width: 300)
                .multilineTextAlignment(.center)
                .padding()
                
            Button {
                cameraPermission.requestCameraPermission()
            } label: {
                Text("Sounds good!")
            }
            .filledBubble()
            .padding()
        }
    }
}


struct CameraPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPermissionsView()
    }
}
