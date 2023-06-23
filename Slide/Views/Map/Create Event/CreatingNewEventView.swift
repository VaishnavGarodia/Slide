//
//  CreatingNewEventView.swift
//  Slide
//
//  Created by Ethan Harianto on 3/4/23.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class SelectedLocation: ObservableObject {
    @Published var details: String = ""
}

struct FindLocationView: View {
    @EnvironmentObject var location: SelectedLocation
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = LocationSearchViewModel()
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            if isSearching {
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                    .ignoresSafeArea()
            }
            
            VStack {
                VStack(alignment: .center) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                            .clipped()
                            .frame(width: 250, height: 40)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search", text: $viewModel.queryFragment, onEditingChanged: { isEditing in
                                isSearching = isEditing
                            })
                        }
                        .padding()
                    }
                    .frame(width: 220)
                }
                
                Divider()
                    .padding(.top, -5)
                
                if isSearching && !viewModel.queryFragment.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.results.filter { $0.subtitle != "Search Nearby" }, id: \.self) { result in
                                Button(action: {
                                    location.details = result.subtitle
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .resizable()
                                            .foregroundColor(.blue)
                                            .accentColor(.white)
                                            .frame(width: 40, height: 40)
                                        
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
                } else {
                    Spacer()
                }
            }
        }
    }
}

struct CreatingNewEventView: View {
    @ObservedObject var location = SelectedLocation()
    @State private var eventName = ""
    @State private var eventDescription = ""
    @State private var eventStart = Date()
    @State private var eventEnd = Date()
    @State private var user = Auth.auth().currentUser
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
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
                .buttonStyle(.borderless)
            }
            .padding()
            
            NavigationLink(destination: FindLocationView().environmentObject(location)) {
                Text("Location")
                    .foregroundColor(.teal)
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 150, height: 50)
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading) {
                Text("Event Name")
                TextField("Your Event Name", text: $eventName)
                DatePicker("Start Time", selection: $eventStart, displayedComponents: [.date, .hourAndMinute])
                    .padding(5)
                DatePicker("End Time", selection: $eventEnd, displayedComponents: [.date, .hourAndMinute])
                    .padding(5)
                Text("Event Description")
                TextField("Your Event Description", text: $eventDescription)
            }
            .padding()
            
            Spacer()
        }
    }
    
    func addEvent() {
        if !location.details.isEmpty {
            guard let username = user?.displayName else {
                return
            }
            
            let eventsRef = db.collection("Events").document(username + eventName + eventStart.formatted(date: .long, time: .shortened))
            
            eventsRef.getDocument { document, _ in
                if let document = document, document.exists {
                    print("Document already exists.")
                } else {
                    eventsRef.setData([
                        "location": location.details,
                        "eventName": eventName,
                        "eventDescription": eventDescription,
                        "eventStart": eventStart,
                        "eventEnd": eventEnd,
                        "username": username
                    ])
                }
            }
        } else {
            print("Location is empty.")
        }
    }
}

struct CreatingNewEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreatingNewEventView()
    }
}
