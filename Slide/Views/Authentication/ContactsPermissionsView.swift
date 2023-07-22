//
//  ContactsPermissionsView.swift
//  Slide
//
//  Created by Ethan Harianto on 7/21/23.
//

import SwiftUI

struct ContactsPermissionsView: View {
    @ObservedObject var contactsPermission = ContactsPermission()
    
    var body: some View {
        VStack(alignment: .center) {
            Image("location_permission")
                .resizable()
                .frame(width: 160, height: 160)
            
            Text("Allow contacts access?")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("We need to know where you are in order to display nearby events")
                .frame(width: 300)
                .multilineTextAlignment(.center)
                .padding()
                
            Button {
                contactsPermission.requestContactsPermission()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                    addContactsToUser(contactList: getContacts(contactsPermission.isContactsPermission))
                }
                
            } label: {
                Text("Sounds good!")
            }
            .filledBubble()
            .padding()
        }
    }
}

struct ContactsPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsPermissionsView()
    }
}
