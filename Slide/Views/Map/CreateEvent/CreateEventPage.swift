//
//  MapPage.swift
//  Slide
//
//  Created by Vaishnav Garodia
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

struct CreateEventPage : View {
    
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var source : CLLocationCoordinate2D!
    @State var destination : CLLocationCoordinate2D!
    @State var name = ""
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var book = false
    @State var doc = ""
    @State var data : Data = .init(count: 0)
    @State var search = false
    let createEventSearch : Bool = true
    
    var body: some View{
        ZStack {
            CreateEventView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, name: self.$name, distance: self.$distance, time: self.$time, show: self.$show)
                .ignoresSafeArea()
                .onAppear {
                    self.manager.requestAlwaysAuthorization()
                }
            ZStack {
                
                VStack {
                    
                    HStack{
                        
                        VStack(alignment: .leading, spacing: 15) {
                            
                            Text(self.destination != nil ? "Destination" : "New Page")
                                .font(.title)
                            
                            if self.destination != nil{
                                
                                Text(self.name)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            
                            self.search.toggle()
                            
                        }) {
                            
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Circle().foregroundColor(.accentColor))
                    }
                    .padding()
                    .background()
                    
                    if self.destination != nil && self.show{
                        
                        ZStack(alignment: .topTrailing){
                            
                            VStack(spacing: 20){
                                
                                HStack{
                                    
                                    VStack(alignment: .leading,spacing: 15){
                                        
                                        Text("Destination")
                                            .fontWeight(.bold)
                                        Text(self.name)
                                        
                                    }
                                    
                                    Spacer()
                                }
                                
                                Button(action: {
                                    
                                    self.loading.toggle()
                                    
                                    self.createEvent()
                                    
                                }) {
                                    
                                    Text("Create Event")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .frame(width: UIScreen.main.bounds.width / 2)
                                }
                                .background(Color.red)
                                .clipShape(Capsule())
                                
                            }
                            
                            Button(action: {
                                
                                self.map.removeOverlays(self.map.overlays)
                                self.map.removeAnnotations(self.map.annotations)
                                self.destination = nil
                                
                                self.show.toggle()
                                
                            }) {
                                
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.white)
                    }
                }
                
                if self.loading{
                    
                    Loader()
                }
                
                if self.book{
                    
                    Booked(data: self.$data, doc: self.$doc, loading: self.$loading, book: self.$book)
                }
                
                if self.search{
                    
                    SearchView(show: self.$search, map: self.$map, source: self.$source, location: self.$destination, name: self.$name, distance: self.$distance, time: self.$time,detail: self.$show, createEventSearch: self.createEventSearch)
                }
            }
        }
        .alert(isPresented: self.$alert) { () -> Alert in
            
            Alert(title: Text("Error"), message: Text("Please Enable Location In Settings !!!"), dismissButton: .destructive(Text("Ok")))
        }
    }
    
    func createEvent(){
        
        let db = Firestore.firestore()
        let doc = db.collection("Events").document()
        self.doc = doc.documentID
        
        let location = GeoPoint(latitude: self.destination.latitude, longitude: self.destination.longitude)
        print("Creating event for location: ", location)
        doc.setData(["name":"Kavsoft","location":location]) { (err) in
            
            if err != nil{
                
                print((err?.localizedDescription)!)
                return
            }
            
        self.loading.toggle()
        self.book.toggle()
            
        }
    }
}


