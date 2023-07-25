//
//  AccountCreationView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/22/23.
//

import SwiftUI

struct AccountCreationView: View {
    @State private var logIn = true
    var body: some View {
        VStack {
            if logIn {
                LogIn(logIn: $logIn)
                    .transition(.move(edge: .leading))
            } else {
                Register(logIn: $logIn)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

struct AccountCreationView_Previews: PreviewProvider {
    static var previews: some View {
        AccountCreationView()
    }
}
