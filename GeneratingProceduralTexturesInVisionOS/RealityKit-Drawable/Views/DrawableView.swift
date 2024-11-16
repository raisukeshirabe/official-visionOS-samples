/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view to randomize the seed of the texture.
*/

import SwiftUI

/// A view that you can use to randomize the seed of the texture.
struct DrawableView: View {
    /// The value controls the randomization of the texture generator.
    @State var seed: Int = 0
    
    var body: some View {
        HStack {
            EntityView(seed: seed)
            
            Divider()
            
            /// The button that increases the seed by 1.
            Button("Regenerate") { seed += 1 }
        }.padding()
    }
}
