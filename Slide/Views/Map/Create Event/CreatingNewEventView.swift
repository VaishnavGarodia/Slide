//
//  CreatingNewEventView.swift
//  Slide
//
//  Created by Ethan Harianto on 3/4/23.
//

import SwiftUI
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class selectedLocation : ObservableObject {
    @Published var details: String
    
    init() {
        details = ""
    }
}

// Inside view
struct findLocationView: View {
    @EnvironmentObject var location: selectedLocation
    @Environment(\.dismiss) var dismiss
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
                VStack (alignment: .center){
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                            .clipped()
                            .frame(width: 250, height: 40)
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search", text: $viewModel.queryFragment, onEditingChanged: { (editingChanged) in
                                if editingChanged {
                                    click.toggle()
                                } else {
                                    click.toggle()
                                }
                            }
                            )
                        }
                        .padding()
                    }
                    .frame(width:220)
                }
                
                Divider()
                    .padding(.top, -5)
                
                if (click && viewModel.queryFragment != "")   {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.results, id: \.self) {result in
                                if result.subtitle != "Search Nearby" {
                                    Button(action: {
                                        location.details = result.subtitle
                                        print(location.details)
                                        dismiss()
                                    }) {
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
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                    }
                }
                else {
                    Spacer()
                }
            }
        }
    }
}


// OutsideView
struct CreatingNewEventView: View {
    @ObservedObject var location = selectedLocation()
    @State private var eventName = ""
    @State private var eventDescription = ""
    @State private var eventStart = Date()
    @State private var eventEnd = Date()
    @State private var user = Auth.auth().currentUser
    var body: some View {
        
        VStack {
            HStack(alignment: .top) {
                
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
                .buttonStyle(.borderless)
                
            }
            .padding()
            
            NavigationLink(destination: findLocationView().environmentObject(location)) {
                Text("Location")
                    .foregroundColor(.teal)
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width:150, height:50)
                            .foregroundColor(.gray)
                    )
            }
            
            
            // I'm keeping this page simpler for now. This will eventually only represent the event name but im allowing it to span the whole page just for the time being since I want to get to the backend functionality sooner. The location buttton kinda weird too...
            // I will also add other text input boxes. Ie times, other notes, overall description, etc.
            //            TextAreaEventDescription("Event Description", text: $eventName)
            VStack(alignment: .leading) {
                Text("Event Name")
                TextField(" Your Event Name", text: $eventName)
                DatePicker("Start Time", selection: $eventStart, displayedComponents: [.date, .hourAndMinute])
                    .padding(5)
                DatePicker("End Time", selection: $eventEnd, displayedComponents: [.date, .hourAndMinute])
                    .padding(5)
                Text("Event Description")
                TextField(" Your Event Description", text: $eventDescription)
            }
            .padding()
            
            Spacer()
        }
    }
    
    // fix conflicts
    func addEvent() {
        if (location.details != "") {
            let username = user?.displayName ??  ""
            let eventsRef = db.collection("Events").document(username + eventName + eventStart.formatted(date: .long, time: .shortened))
            print("Check:")
            print(eventsRef)
            eventsRef.getDocument {(document, error) in
                if let document = document, document.exists {
                    print("")
                }
                eventsRef.setData([
                    "location" : location.details,
                    "eventName" : eventName,
                    "eventDescription": eventDescription,
                    "eventStart": eventStart,
                    "eventEnd": eventEnd,
                    "username": username
                ])
            }
        }
        else {
            print("error")
        }
    }
}



struct CreatingNewEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreatingNewEventView()
    }
}
