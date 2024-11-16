/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension on CaseIterable with useful functions.
*/

import Foundation
import RealityKit
import SwiftUI

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex: next]
    }
}
