//  EventDrawer.swift
//  Slide
//  Created by Ethan Harianto on 8/16/23.

import MapKit
import SwiftUI

struct EventDrawer: View {
    @Binding var events: [Event]
    @Binding var selectedEvent: Event
    @Binding var map: MKMapView
    @Binding var eventView: Bool
    // Gesture Properties...
    @State var offset: CGFloat = 10
    @State var lastOffset: CGFloat = 0
    @State var storedOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy -> AnyView in
            let height = proxy.frame(in: .global).height
            return AnyView(
                ZStack {
                    BlurView(style: .systemThinMaterial)
                        .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 20))
                        .edgesIgnoringSafeArea(.bottom)

                    if eventView {
                        VStack {
                            EventDetailsView(
                                event: $selectedEvent,
                                eventView: $eventView
                            )
                            .onAppear {
                                withAnimation {
                                    storedOffset = offset
                                    offset = -(height - 30)
                                }
                                let coordinateRegion = MKCoordinateRegion(
                                    center: selectedEvent.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                )
                                map.setRegion(coordinateRegion, animated: true)
                            }
                            .onDisappear {
                                withAnimation {
                                    offset = storedOffset
                                }
                            }
                            Spacer()
                        }

                    } else {
                        VStack {
                            Capsule()
                                .fill(.primary)
                                .frame(width: 60, height: 4)
                                .padding(.top, -5)

                            ScrollView {
                                ForEach($events, id: \.name) { event in
                                    ListedEvent(event: event, selectedEvent: $selectedEvent, eventView: $eventView)
                                }
                                .padding(.bottom)
                            }

                            Divider()
                                .background(.white)

                            Spacer()
                        }
                        .padding()
                    }
                } //: ZSTACK
                .offset(y: height - 30)
                .offset(y: -offset > 10 ? -offset <= (height - 30) ? offset : -(height - 30) : 0)
                .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                    out = value.translation.height
                    onChange()
                }).onEnded { _ in
                    let maxHeight = height - 30
                    withAnimation {
                        // Logic Conditions For Moving States....
                        // Up down or mid...
                        if -offset > 30, -offset < maxHeight / 3, offset < lastOffset {
                            // Mid...
                            if !eventView {
                                offset = (-(maxHeight / 3) > -CGFloat(events.count * 100) + 20 || -(maxHeight / 3) < -CGFloat(events.count * 100) - 20) ? -CGFloat(events.count * 100) : -(maxHeight / 3)
                            } else {
                                offset = 10
                            }
                        } else if -offset > maxHeight / 3 {
                            if !eventView {
                                offset = (events.count >= 7 || eventView) ? -maxHeight : -CGFloat(events.count * 100)
                            } else {
                                offset = -maxHeight
                            }
                        } else {
                            offset = 10
                        }
                    }

                    // Storing Last Offset...
                    // So that the gesture can contine from the last position....
                    lastOffset = offset
                })
            )
        }
    }

    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
}
