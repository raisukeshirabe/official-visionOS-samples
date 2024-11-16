/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A data model for the app state.
*/

import SwiftUI

// Maintains an app-wide state.
@Observable
public class AppModel {
    public var showImmersiveSpace = false
    public var immersiveSpaceIsShown = false
}
