//
//  ListPage.swift
//  Slide
//
//  Created by Ethan Harianto on 12/21/22.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ListPage: View {
    @Binding var events: [EventData]
    var body: some View {
        ScrollView {
            List {
                ForEach($events, id: \.address) {event in
                    ListedEvent(event: event)
                }
            }
        }
    }
}

struct EventData {
    var name, description, host, address, start, end, hostUID, icon: String
}

struct ListPage_Previews: PreviewProvider {
    static var previews: some View {
        ListPage(events: .constant([]))
    }
}
