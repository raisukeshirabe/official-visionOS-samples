/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Constant values that the app defines.
*/

import SwiftUI

///  Constant values that the app defines.
struct Constants {
    static var cardSpacing: Double {
        #if os(tvOS)
        50
        #else
        20
        #endif
    }
    
    static var cardPadding: Double {
        #if os(tvOS)
        30
        #else
        20
        #endif
    }
    
    static var heroTextMargin: Double {
        #if os(visionOS)
        500
        #elseif os(tvOS)
        800
        #else
        500
        #endif
    }
    
    static var heroViewHeight: Double {
        #if os(visionOS)
        550
        #else
        900
        #endif
    }
    
    static var extendSafeAreaTV: Double {
        #if os(tvOS)
        160
        #else
        0
        #endif
    }

    static var heroSafeAreaHeight: Double {
        #if os(macOS)
        40
        #elseif os(tvOS)
        120
        #elseif os(visionOS)
        0
        #else
        100
        #endif
    }
    
    static var detailSafeAreaHeight: Double {
        #if os(macOS)
        40
        #elseif os(visionOS)
        100
        #else
        90
        #endif
    }
    
    static var detailPadding: Double {
        #if os(tvOS)
        30
        #else
        50
        #endif
    }

    static let compactDetailSafeAreaHeight: Double = 100

    static let compactSafeAreaHeight: Double = 65
    
    static let gradientSize: Double = 650

    static let compactGradientSize: Double = 400

    static let cornerRadius: Double = 10.0
    
    static var outerPadding: Double {
        #if os(visionOS)
        50
        #elseif os(tvOS)
        0
        #else
        20
        #endif
    }
    
    static var videoCardWidth: Double {
        #if os(tvOS)
        550
        #elseif os(macOS)
        250
        #else
        300
        #endif
    }
    
    static let compactVideoCardWidth: Double = 200
    
    static var upNextVideoCardWidth: Double {
        #if os(tvOS)
        400
        #else
        200
        #endif
    }
    
    static var categoryTopPadding: Double {
        #if os(macOS)
        5
        #else
        0
        #endif
    }
    
    static var stackImageWidth: Double {
        #if os(tvOS)
        400
        #elseif os(macOS)
        180
        #else
        250
        #endif
    }
    
    static let stackImageCompactWidth: Double = 150
    
    static let verticalTextSpacing: Double = 15

    static let detailCompactPadding: Double = 20
    
    static let detailTrailingPadding: Double = 100
    
    static let genreSpacing: Double = 8

    static let genreVerticalPadding: Double = 3

    static let genreHorizontalPadding: Double = 8
    
    static let trailerHeight: Double = 450
    
    static let playerWindowHeight: Double = 512
    
    static let playerWindowWidth: Double = 960
    
    static let contentWindowHeight: Double = 600
    
    static let contentWindowWidth: Double = 960
    
    static var watchNowSpacing: Double {
        #if os(macOS)
        5
        #else
        0
        #endif
    }
    
    static var listTitleVerticalPadding: Double {
        #if os(iOS) || os(visionOS)
        5
        #else
        0
        #endif
    }

    static var controllerPreferredHeight: Double {
        #if os(tvOS)
        250
        #else
        150
        #endif
    }
    
    static let libraryColumnCountCompact: Int = 2
    
    static var libraryColumnCount: Int {
        #if os(iOS)
        3
        #else
        4
        #endif
    }
}
