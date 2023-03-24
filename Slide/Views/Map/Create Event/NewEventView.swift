//
//  NewEventView.swift
//  Slide
//
//  Created by Thomas Shundi on 2/19/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct NewEventView: View {
    @State private var eventName = ""
    @State private var eventDescription = ""
    @State private var eventStart = Date()
    @State private var eventEnd = Date()
    @State private var user = Auth.auth().currentUser
    var body: some View {
        
        VStack {
            HStack(alignment: .top) {
                Button {
                    print("Dismiss")
                } label: {
                    Text("Cancel")
                        .foregroundColor(Color(.systemBlue))
                }
                
                Spacer()
                
                Button {
                    addEvent()
                } label: {
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
            
            // link this to other bs you dumbass mf
            NavigationLink(destination:  EventSearchHomeView()) {
                Text("Location")
                    .foregroundColor(Color(.systemTeal))
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                
                    .background(
                        Capsule()
                            .frame(width:150, height:50)
                    )
            }
            
            // I'm keeping this page simpler for now. This will eventually only represent the event name but im allowing it to span the whole page just for the time being since I want to get to the backend functionality sooner. The location buttton kinda weird too...
            // I will also add other text input boxes. Ie times, other notes, overall description, etc.
            //            TextAreaEventDescription("Event Description", text: $eventName)
            TextField("Event Name", text: $eventName)
            DatePicker("Start Time", selection: $eventStart, displayedComponents: [.date, .hourAndMinute])
            DatePicker("End Time", selection: $eventEnd, displayedComponents: [.date, .hourAndMinute])
            TextField("Event Description", text: $eventDescription)
            Spacer()
        }
    }
    func addEvent() {
        let username = user?.displayName ??  ""
        let eventsRef = db.collection("Events").document(username + eventName + eventStart.formatted(date: .numeric, time: .shortened))
        eventsRef.getDocument {(document, error) in
            if let document = document, document.exists {
                print("error")
            }
            eventsRef.setData([
                "eventName" : eventName,
                "eventDescription": eventDescription,
                "eventStart": eventStart,
                "eventEnd": eventEnd,
                "username": username
            ])
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
    }
}
