//
//  NewEventView.swift
//  Slide
//
//  Created by Thomas Shundi on 2/19/23.
//

import SwiftUI

struct NewEventView: View {
    @State private var eventName = ""
    
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
                    print("Post")
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

            Button{
                print("Location")
            }label: {
                Text("Location")
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.lightGray))
                    .clipShape(Capsule())
            }
            
            // I'm keeping this page simpler for now. This will eventually only represent the event name but im allowing it to span the whole page just for the time being since I want to get to the backend functionality sooner. The location buttton kinda weird too...
            // I will also add other text input boxes. Ie times, other notes, overall description, etc.
            TextAreaEventDescription("Event Name", text: $eventName)

        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
    }
}
