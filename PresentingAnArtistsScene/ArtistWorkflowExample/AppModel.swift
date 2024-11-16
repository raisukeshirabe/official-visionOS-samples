/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The data model of the app.
*/

import SwiftUI

/// Maintains the app-wide state.
@Observable
public class AppModel {
    public var showImmersiveSpace = false
    public var immersiveSpaceIsShown = false
}
