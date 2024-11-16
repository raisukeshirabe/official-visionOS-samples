/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The modules that the app can present.
*/


import Foundation

/// A description of the modules that the app can present.
enum Module: String, Identifiable, CaseIterable, Equatable {
    case globe, orbit, solar
    var id: Self { self }
    var name: String { rawValue.capitalized }

    var eyebrow: String {
        switch self {
        case .globe:
            String(localized: "A Day in the Life", comment: "The subtitle of the Planet Earth module.")
        case .orbit:
            String(localized: "Our Nearby Neighbors", comment: "The subtitle of the Objects in Orbit module.")
        case .solar:
            String(localized: "Soaring Through Space", comment: "The subtitle of the Solar System module.")
        }
    }

    var heading: String {
        switch self {
        case .globe:
            String(localized: "Planet Earth", comment: "The title of a module in the app.")
        case .orbit:
            String(localized: "Objects in Orbit", comment: "The title of a module in the app.")
        case .solar:
            String(localized: "The Solar System", comment: "The title of a module in the app.")
        }
    }

    var abstract: String {
        switch self {
        case .globe:
            String(localized: "A lot goes into making a day happen on Planet Earth! Discover how our globe turns and tilts to give us hot summer days, chilly autumn nights, and more.", comment: "Detail text explaining the Planet Earth module.")
        case .orbit:
            String(localized: "Get up close with different types of orbits to learn more about how satellites and other objects move in space relative to the Earth.", comment: "Detail text explaining the Objects in Orbit module.")
        case .solar:
            String(localized: "Take a trip to the solar system and watch how the Earth, Moon, and its satellites are in constant motion rotating around the Sun.", comment: "Detail text explaining the Solar System module.")
        }
    }

    var overview: String {
        switch self {
        case .globe:
            String(localized: "You can’t feel it, but Earth is constantly in motion. All planets spin on an invisible axis: ours makes one full turn every 24 hours, bringing days and nights to our home.\n\nWhen your part of the world faces the Sun, it’s daytime; when it rotates away, we move into night. When you see a sunrise or sunset, you’re witnessing the Earth in motion.\n\nWant to explore Earth’s rotation and axial tilt? Check out our interactive 3D globe and be hands-on with Earth’s movements.", comment: "Educational text displayed in the Planet Earth module.")
        case .orbit:
            String(localized: "The Moon orbits the Earth in an elliptical orbit. It’s the most visible object in our sky, but it’s farther from us than you might think: on average, it’s about 385,000 kilometers away!\n\nMost satellites orbit Earth in a tighter orbit — some only a few hundred miles above Earth’s surface. Satellites in lower orbits circle us faster: the Hubble Telescope is approximately 534 kilometers from Earth and completes almost 15 orbits in a day, while geostationary satellites circle Earth just once in 24 hours from about 36,000 kilometers away.\n\nGet up close with different types of orbits to learn how these objects move in space relative to Earth.", comment: "Educational text displayed in the Objects in Orbit module.")
        case .solar:
            String(localized: "Every 365¼ days, Earth and its satellites completely orbit the Sun — the star that anchors our solar system. It’s a journey of about 940 million kilometers a year!\n\nOn its journey, the Earth moves counter-clockwise in a slightly elliptical orbit. It travels a path called the ecliptic plane — an important part of how we navigate through our solar system.\n\nWant to explore Earth’s orbit in detail? Take a trip to the solar system and watch how Earth and its satellites move around the Sun.", comment: "Educational text displayed in the Solar System module.")
        }
    }

    var callToAction: String {
        switch self {
        case .globe: String(localized: "View Globe", comment: "An action the viewer can take in the Planet Earth module.")
        case .orbit: String(localized: "View Orbits", comment: "An action the viewer can take in the Objects in Orbit module.")
        case .solar: String(localized: "View Outer Space", comment: "An action the viewer can take in the Solar System module.")
        }
    }

    static let funFacts = [
        String(localized: "The Earth orbits the Sun on an invisible path called the ecliptic plane.", comment: "An educational fact displayed in the Solar System module."),
        String(localized: "All planets in the solar system orbit within 3°–7° of this plane.", comment: "An educational fact displayed in the Solar System module."),
        String(localized: "As the Earth orbits the Sun, its axial tilt exposes one hemisphere to more sunlight for half of the year.", comment: "An educational fact displayed in the Solar System module."),
        String(localized: "Earth’s axial tilt is why different hemispheres experience different seasons.", comment: "An educational fact displayed in the Solar System module.")
    ]
}
