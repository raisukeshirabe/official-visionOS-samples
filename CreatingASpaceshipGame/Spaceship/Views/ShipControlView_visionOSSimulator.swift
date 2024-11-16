/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
ShipControlView specialized for use on visionOS simulator.
*/

#if os(visionOS) && targetEnvironment(simulator)

import SwiftUI

@MainActor
struct SimulatorShipControlView: View {

    @State var controlParameters: ShipControlParameters

    var body: some View {
        HStack() {
            ShipControlView(controlParameters: controlParameters)
                .frame(width: 300, height: 300)
        }
        .padding([.leading, .trailing], 30)
    }
}

#endif
