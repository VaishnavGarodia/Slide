//
//  NewEventView.swift
//  Slide
//
//  Created by Thomas Shundi on 2/19/23.
//

import FirebaseAuth
import FirebaseStorage
import SwiftUI

struct NewEventView: View {
    @State private var eventName = ""
    @State private var eventDescription = ""
    @State private var eventStart = Date()
    @State private var eventEnd = Date()
    @State private var user = Auth.auth().currentUser
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Button(action: {
                    print("Dismiss")
                }) {
                    Text("Cancel")
                        .foregroundColor(Color(.systemBlue))
                }
                
                Spacer()
                
                Button(action: {
                    addEvent()
                }) {
                    Text("Post")
                        .foregroundColor(Color(.systemBlue))
                        .bold()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.lightGray))
                        .clipShape(Capsule())
                }
            }
            .padding()
            
            NavigationLink(destination: EventSearchHomeView()) {
                Text("Location")
                    .foregroundColor(Color(.systemTeal))
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .frame(width: 150, height: 50)
                    )
            }
            
            TextField("Event Name", text: $eventName)
            DatePicker("Start Time", selection: $eventStart, displayedComponents: [.date, .hourAndMinute])
            DatePicker("End Time", selection: $eventEnd, displayedComponents: [.date, .hourAndMinute])
            TextField("Event Description", text: $eventDescription)
            
            Spacer()
        }
    }

    func addEvent() {
        guard let username = user?.displayName else {
            return
        }
        
        let eventsRef = db.collection("Events").document(username + eventName + eventStart.formatted(date: .numeric, time: .shortened))
        
        eventsRef.getDocument { document, _ in
            if let document = document, document.exists {
                print("Document already exists.")
            } else {
                eventsRef.setData([
                    "eventName": eventName,
                    "eventDescription": eventDescription,
                    "eventStart": eventStart,
                    "eventEnd": eventEnd,
                    "username": username
                ])
            }
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
    }
}
