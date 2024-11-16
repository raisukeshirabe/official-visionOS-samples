/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
View for picking surroundings.
*/

import SwiftUI

struct SurroundingsPicker: View {

    @Binding var selection: Surroundings

    var body: some View {

        Grid {
            GridRow {
                Toggle(isOn: binding(surroundings: .passthrough)) {
                    Text(Surroundings.passthrough.displayName)
                }
                Toggle(isOn: binding(surroundings: .studio)) {
                    Text(Surroundings.studio.displayName)
                }
            }
            GridRow {
                Toggle(isOn: binding(surroundings: .outerSpace)) {
                    Text(Surroundings.outerSpace.displayName)
                }
                Toggle(isOn: binding(surroundings: .deepSpace)) {
                    Text(Surroundings.deepSpace.displayName)
                }
            }
        }
        .toggleStyle(SurroundingsToggleStyle())
    }

    func binding(surroundings: Surroundings) -> Binding<Bool> {
        Binding(
            get: {
                selection == surroundings
            },
            set: { isSelected in
                if isSelected {
                    selection = surroundings
                }
            }
        )
    }
}

struct SurroundingsToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                .frame(width: 110, height: 90)
        }
        .buttonBorderShape(.roundedRectangle)
    }
}
