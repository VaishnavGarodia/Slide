//  DraggingComponent.swift
//  Slide
//  Created by Ethan Harianto on 8/14/23.

import SwiftUI
import CoreHaptics

struct DraggingComponent: View {

    @Binding var isRSVPed: Bool
    let isLoading: Bool
    let maxWidth: CGFloat

    @State private var width = CGFloat(50)
    private  let minWidth = CGFloat(50)

    public init(isRSVPed: Binding<Bool>, isLoading: Bool, maxWidth: CGFloat) {
        _isRSVPed = isRSVPed
        self.isLoading = isLoading
        self.maxWidth = maxWidth
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.accentColor)
            .opacity(width / maxWidth)
            .frame(width: width)
            .overlay(
                Button(action: { }) {
                    ZStack {
                        image(name: "arrowshape.right", isShown: isRSVPed)
                        progressView(isShown: isLoading)
                        image(name: "arrowshape.right.fill", isShown: !isRSVPed && !isLoading)
                    }
                    .animation(.easeIn(duration: 0.35).delay(0.55), value: !isRSVPed && !isLoading)
                }
                .buttonStyle(BaseButtonStyle())
                .disabled(!isRSVPed || isLoading),
                alignment: .trailing
            )

            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        guard isRSVPed else { return }
                    if value.translation.width > 0 {
                        width = min(max(value.translation.width + minWidth, minWidth), maxWidth)
                    }
                    }
                    .onEnded { value in
                        guard isRSVPed else { return }
                        if width < maxWidth {
                            width = minWidth
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            withAnimation(.spring().delay(0.5)) {
                                isRSVPed = false
                            }
                        }
                    }
            )
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0), value: width)

    }

    private func image(name: String, isShown: Bool) -> some View {
        Image(systemName: name)
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .foregroundColor(Color.blue)
            .frame(width: 42, height: 42)
            .background(RoundedRectangle(cornerRadius: 14).fill(.white))
            .padding(4)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
    }

    private func progressView(isShown: Bool) -> some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.white)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
    }

}
