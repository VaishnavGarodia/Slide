//  Event.swift
//  Slide
//  Created by Ethan Harianto on 8/9/23.

import SwiftUI
import CoreLocation

struct Event {
    var name, description, eventIcon, host: String
    var start, end: Date
    var address: String
    var location: CLLocationCoordinate2D
}
