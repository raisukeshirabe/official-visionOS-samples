/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A PreviewModifier for the AppState environment `#Preview`'s should be in.
*/
import SwiftUI

struct SampleAppStateEnvironment: PreviewModifier {
    static func makeSharedContext() async throws -> AppState {
        AppState()
    }

    func body(content: Content, context: AppState) -> some View {
        content
            .environment(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleAppState: Self = .modifier(SampleAppStateEnvironment())
}
