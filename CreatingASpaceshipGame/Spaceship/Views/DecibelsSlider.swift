/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Custom view for decibel sliders.
*/

import SwiftUI

struct DecibelsSlider: View {

    let name: String
    @Binding var decibels: Double

    var decibelsDisplay: String {
        decibels.formatted(.number.precision(.fractionLength(1))) + "dB"
    }

    var body: some View {
        VStack {
            HStack {
                Text(name)
                    .bold()
                Spacer()
                Text(decibelsDisplay)
                    .monospacedDigit()
            }

            Slider(value: $decibels, in: -60...0)
        }
    }
}
