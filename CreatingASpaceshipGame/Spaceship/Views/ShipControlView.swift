/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Reusable UI-based ship control views, for use on visionOS simulator and iOS .
*/

import SwiftUI
import simd

@MainActor
struct ThrottleControlView: View {

    @State var controlParameters: ShipControlParameters
    let sliderWidth: CGFloat
    var sliderHeight: CGFloat { sliderWidth * 2 }

    @State var sliderValue: CGFloat = .zero

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(BackgroundStyle.background.secondary)
                    .opacity(0.3)
                    .hoverEffect()
                    .frame(width: sliderWidth,
                           height: sliderHeight)
                    .gesture(DragGesture(minimumDistance: 0.0).onChanged({ gesture in
                        sliderValue = 1.0 - gesture.location.y / sliderHeight
                        sliderValue = max(sliderValue, 0)
                        sliderValue = min(sliderValue, 1)
                        controlParameters.throttle = Float(sliderValue)
                    }))

                Rectangle()
                    .fill(.gray)
                    .opacity(0.4)
                    .frame(width: sliderWidth,
                           height: sliderHeight)
                    .offset(y: (1 - sliderValue) * sliderHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            Text("Throttle")
        }
    }
}

@MainActor
struct PitchRollControlView: View {
    let maximumShipRotation: Angle = .degrees(90)

    @State var controlParameters: ShipControlParameters
    let joystickRadius: CGFloat
    let joystickHandleRadius: CGFloat

    @State var offset: SIMD2<Double> = .zero
    @State var location: SIMD2<Double> = .zero

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(BackgroundStyle.background.secondary)
                    .opacity(0.3)
                    .hoverEffect()
                    .frame(width: joystickRadius * 2, height: joystickRadius * 2)
                    .gesture(DragGesture(minimumDistance: 0.0).onChanged({ gesture in
                        location = SIMD2<Double>(x: gesture.location.x, y: gesture.location.y)
                        location -= .init(repeating: joystickRadius)
                        let maxMovementRadius = joystickRadius - joystickHandleRadius
                        if simd_length(location) > maxMovementRadius {
                            location *= maxMovementRadius / simd_length(location)
                        }
                        offset.x = location.x
                        offset.y = location.y
                        controlParameters.roll = -Float(offset.x / maxMovementRadius * maximumShipRotation.radians)
                        controlParameters.pitch = -Float(offset.y / maxMovementRadius * maximumShipRotation.radians)
                    }))

                Circle()
                    .fill(.gray)
                    .opacity(0.4)
                    .frame(width: joystickHandleRadius * 2, height: joystickHandleRadius * 2)
                    .offset(x: offset.x, y: offset.y)
            }

            Text("Pitch & Roll")
        }
    }
}

@MainActor
struct ShipControlView: View {

    @State var controlParameters: ShipControlParameters
    @State var offset: SIMD2<Double> = .zero
    @State var location: SIMD2<Double> = .zero

    var body: some View {
        HStack {
            ThrottleControlView(controlParameters: controlParameters,
                                sliderWidth: 100)
            Spacer()

            PitchRollControlView(controlParameters: controlParameters,
                                 joystickRadius: 100,
                                 joystickHandleRadius: 10)
        }
    }
}
