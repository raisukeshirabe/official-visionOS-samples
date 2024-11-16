/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Debug setting controls for the solar system module.
*/

import SwiftUI

/// Debug setting controls for the solar system module.
struct SolarSystemSettings: View {
    @Environment(ViewModel.self) private var model

    var body: some View {
        @Bindable var model = model
        
        VStack {
            Text("Solar system module debug settings", comment: "The title of the settings presented to the viewer.")
                .font(.title)
            Form {
                EarthSettings(configuration: $model.solarEarth)
                SatelliteSettings(configuration: $model.solarSatellite)
                SatelliteSettings(configuration: $model.solarMoon)
                Section(String(localized: "Sun", comment: "Section title of settings for the sun.")) {
                    Grid(alignment: .leading, verticalSpacing: 20) {
                        SliderGridRow(
                            title: String(localized: "Distance to Earth"),
                            value: $model.solarSunDistance,
                            range: 0 ... 1e3)
                    }
                }
                Section(String(localized: "System", comment: "Section title of system level settings.")) {
                    Grid(alignment: .leading, verticalSpacing: 20) {
                        Button(String(localized: "Reset", comment: "Action to reset all settings to their defaults.")) {
                            model.solarEarth = .solarEarthDefault
                            model.solarSatellite = .solarTelescopeDefault
                            model.solarMoon = .solarMoonDefault
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SolarSystemSettings()
        .frame(width: 500)
        .environment(ViewModel())
}
