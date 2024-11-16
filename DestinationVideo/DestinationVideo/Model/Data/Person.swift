/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model class that defines the properties of a person.
*/

import Foundation
import SwiftData

/// A model class that defines the properties of a person.
@Model
final class Person {
    @Relationship
    var appearsIn: [Video]
    
    @Relationship
    var wrote: [Video]
    
    @Relationship
    var directed: [Video]
    
    var id: Int
    var initial: String
    var surname: String
    
    init(
        id: Int,
        initial: String,
        surname: String,
        appearsIn: [Video] = [],
        wrote: [Video] = [],
        directed: [Video] = []
    ) {
        self.appearsIn = appearsIn
        self.wrote = wrote
        self.directed = directed
        self.id = id
        self.initial = initial
        self.surname = surname
    }
}

extension Person {
    var displayName: String {
        PersonNameComponents(givenName: initial, familyName: surname).formatted()
    }
}

extension SampleData {
    @MainActor static let people = [
        Person(id: 0, initial: "A", surname: "Cloud"),
        Person(id: 1, initial: "A", surname: "Leaf"),
        Person(id: 2, initial: "A", surname: "Tent"),
        Person(id: 3, initial: "B", surname: "Misty"),
        Person(id: 4, initial: "B", surname: "Skies"),
        Person(id: 5, initial: "D", surname: "Lily"),
        Person(id: 6, initial: "E", surname: "Reed"),
        Person(id: 7, initial: "F", surname: "Log"),
        Person(id: 8, initial: "G", surname: "Grass"),
        Person(id: 9, initial: "G", surname: "Run"),
        Person(id: 10, initial: "G", surname: "Seaglass"),
        Person(id: 11, initial: "J", surname: "Sun"),
        Person(id: 12, initial: "K", surname: "Dark"),
        Person(id: 13, initial: "K", surname: "Green"),
        Person(id: 14, initial: "L", surname: "Misty"),
        Person(id: 15, initial: "L", surname: "Shore"),
        Person(id: 16, initial: "L", surname: "Windy"),
        Person(id: 17, initial: "M", surname: "Seagull"),
        Person(id: 18, initial: "M", surname: "Turtle"),
        Person(id: 19, initial: "N", surname: "Hide"),
        Person(id: 20, initial: "N", surname: "Sand"),
        Person(id: 21, initial: "A", surname: "Cloud"),
        Person(id: 22, initial: "O", surname: "Scary"),
        Person(id: 23, initial: "P", surname: "Sky"),
        Person(id: 24, initial: "R", surname: "Hill"),
        Person(id: 25, initial: "R", surname: "Rock"),
        Person(id: 26, initial: "S", surname: "Dandy"),
        Person(id: 27, initial: "S", surname: "Sticks"),
        Person(id: 28, initial: "T", surname: "Daisy"),
        Person(id: 29, initial: "U", surname: "Brush"),
        Person(id: 30, initial: "U", surname: "Dare"),
        Person(id: 31, initial: "V", surname: "Sunny"),
        Person(id: 32, initial: "V", surname: "Water"),
        Person(id: 33, initial: "Z", surname: "Splash")
    ]
}
