/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Settings for the satellite entities.
*/

import SwiftUI

/// Controls for settings that relate to a satellite entity.
struct SatelliteSettings: View {
    @Binding var configuration: SatelliteEntity.Configuration

    var body: some View {
        Section(configuration.displayName) {
            Grid(alignment: .leading, verticalSpacing: 20) {
                Toggle(String(localized: "Visible", comment: "A toggle to control the satellite's visibility."), isOn: $configuration.isVisible)
                SliderGridRow(
                    title: String(localized: "Speed ratio", comment: "A slider control to change the speed ratio of the satellite."),
                    value: $configuration.speedRatio,
                    range: 0 ... 50,
                    fractionLength: 1)
                SliderGridRow(
                    title: String(localized: "Altitude", comment: "A slider control to change the altitude of the satellit's orbit."),
                    value: $configuration.altitude,
                    range: 0 ... 10,
                    fractionLength: 2)
                SliderGridRow(
                    title: String(localized: "Inclination", comment: "A slider control to change the inclination of the satellite's orbit."),
                    value: inclinationBinding,
                    range: 0 ... 90,
                    fractionLength: 0)
                SliderGridRow(
                    title: String(localized: "Scale", comment: "A slider control to change the scale of the satellite."),
                    value: $configuration.scale,
                    range: 0 ... 5,
                    fractionLength: 2)

                Divider()

                Toggle("Trace", isOn: $configuration.isTraceVisible)
                SliderGridRow(
                    title: String(localized: "Trace width", comment: "A slider control to change the with of the trace the satellite's orbit draws."),
                    value: $configuration.traceWidth,
                    range: 0 ... 1000)
            }
        }
    }

    var inclinationBinding: Binding<Float> {
        Binding<Float>(
            get: { Float(configuration.inclination.degrees) },
            set: { configuration.inclination = .degrees(Double($0)) }
        )
    }
}

