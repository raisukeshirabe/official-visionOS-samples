/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Debug setting controls for the globe module.
*/

import SwiftUI

/// Debug setting controls for the globe module.
struct GlobeSettings: View {
    @Environment(ViewModel.self) private var model

    var body: some View {
        @Bindable var model = model
        
        VStack {
            Text("Globe module debug settings", comment: "The title of the settings presented to the viewer.")
                .font(.title)
            Form {
                EarthSettings(configuration: $model.globeEarth)
                Section(String(localized: "System", comment: "Section title of system level settings.")) {
                    Grid(alignment: .leading, verticalSpacing: 20) {
                        Button {
                            model.globeEarth = .globeEarthDefault
                        } label: {
                            Text("Reset", comment: "Action to reset the settings to their default values.")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    GlobeSettings()
        .frame(width: 500)
        .environment(ViewModel())
}
