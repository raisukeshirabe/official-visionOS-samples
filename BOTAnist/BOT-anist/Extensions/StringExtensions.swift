/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension on String containing useful functions.
*/

import Foundation

extension String {
    func capitalizedFirst() -> String {
        return "\(prefix(1).capitalized)\(dropFirst())"
    }
}
