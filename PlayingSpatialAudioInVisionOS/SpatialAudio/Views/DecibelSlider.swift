/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A slider that formats for decibels.
*/

import SwiftUI

/// A view that formats as a slider to adjust decibel values.
struct DecibelSlider: View {
    /// The name of the value that changes.
    let name: String
    
    /// The binding to a numerical double that stores the decibel value.
    let value: Binding<Double>

    var body: some View {
        VStack {
            HStack {
                Text(name)
                Spacer()
                Text(value.wrappedValue.formatted(.number.precision(.fractionLength(.zero))) + "dB")
                    .monospacedDigit()
            }
            
            /// The slider with a range of -60 to 0.
            Slider(value: value, in: -60 ... 0)
        }
    }
}
