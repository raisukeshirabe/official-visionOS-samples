/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
ShipControlView specialized for use on iOS.
*/

#if os(iOS)

import RealityKit
import SwiftUI

@MainActor
struct MultiTouchControlView: View {

    @State var controlParameters: ShipControlParameters
    var body: some View {
        VStack {
            Spacer()
            
            ShipControlView(controlParameters: controlParameters)
        }
        .padding()
        .scaledToFit()
    }
}

#endif
