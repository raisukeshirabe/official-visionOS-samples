/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Settings for the Earth entity.
*/

import SwiftUI

/// Controls for settings specific to the Earth entity.
struct EarthSettings: View {
    @Binding var configuration: EarthEntity.Configuration

    private var solarSunAngleBinding: Binding<Double> {
        Binding<Double>(
            get: { configuration.sunAngle.degrees },
            set: { configuration.sunAngle = .degrees($0) }
        )
    }

    var body: some View {
        Section(String(localized: "Earth", comment: "Section title of the settings for Earth.")) {
            Grid(alignment: .leading, verticalSpacing: 20) {
                SliderGridRow(
                    title: String(localized: "Scale", comment: "The scale the Earth is presented at."),
                    value: $configuration.scale,
                    range: 0 ... 1e3)
                SliderGridRow(
                    title: String(localized: "Rotation speed", comment: "A setting to change the rotation speed of the Earth."),
                    value: $configuration.speed,
                    range: 0 ... 1,
                    fractionLength: 3)

                Divider()

                SliderGridRow(
                    title: String(localized: "X", comment: "A slider to change the Earth location in the 3d volume along the X axis."),
                    value: $configuration.position.x,
                    range: -10 ... 10)
                SliderGridRow(
                    title: String(localized: "Y", comment: "A slider to change the Earth location in the 3d volume along the Y axis."),
                    value: $configuration.position.y,
                    range: -10 ... 10)
                SliderGridRow(
                    title: String(localized: "Z", comment: "A slider to change the Earth location in the 3d volume along the Z axis."),
                    value: $configuration.position.z,
                    range: -10 ... 10)

                Divider()

                Toggle(isOn: $configuration.showPoles) {
                    Text("Show Poles", comment: "A toggle to change whether the poles are marked on the Earth display.")
                }
                SliderGridRow(
                    title: String(localized: "Pole height",
                                  comment: "A numerical setting for how much the pole indicators stick out from the Earth display."),
                    value: $configuration.poleLength,
                    range: 0 ... 1,
                    fractionLength: 3)
                SliderGridRow(
                    title: String(localized: "Pole thickness",
                                  comment: "A numerical setting for how large the pole indicators are on the Earth display."),
                    value: $configuration.poleThickness,
                    range: 0 ... 1,
                    fractionLength: 3)
            }
        }
        Section(String(localized: "Sun", comment: "A section of settings that control the Sun in the Earth display.")) {
            Grid(alignment: .leading, verticalSpacing: 20) {
                Toggle(isOn: $configuration.showSun) {
                    Text("Show Sun", comment: "A toggle to change whether there is sunlight shown on the Earth display.")
                }
                SliderGridRow(
                    title: String(localized: "Sun intensity", comment: "A setting to control the intensity of the sunlight."),
                    value: $configuration.sunIntensity,
                    range: 0 ... 20)
                SliderGridRow(
                    title: String(localized: "Angle", comment: "A setting to control which angle the sunlight is coming from."),
                    value: solarSunAngleBinding,
                    range: 0 ... 360)
            }
        }
    }
}
