/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's sample data.
*/

import Foundation

/// The app's sample data.
struct SampleData { }

extension SampleData {
    @MainActor static let videos = [
        Video(
            id: 0,
            name: "A BOT-anist Adventure",
            synopsis: """
                An awe-inspiring tale of a beloved robot, on a quest to save extraordinary vegetation from extinction. \
                Uncover the mysterious plant life inhabiting an alien planet, \
                and cheer on the robot botanist as it sets out to discover and save new and exciting plants.
                """,
            categoryIDs: [
                1000,
                1004,
                1005
            ],
            url: URL(string: "file://BOT-anist_video.mov")!,
            imageName: "BOT-anist",
            yearOfRelease: 2024,
            duration: 66,
            contentRating: "NR",
            isHero: true
        ),
        
        Video(
            id: 1,
            name: "Landing",
            synopsis: """
                After a long journey through the stars, the robot botanist and its trusty spaceship finally arrive at Wolf 1069 B, \
                ready to explore the mysteries that lie on the planet’s surface. \
                New plants to catalog, new animals to discover, and cool rocks to unearth. Follow along as the botanist’s mission begins!
                """,
            categoryIDs: [
                1004,
                1005
            ],
            url: URL(string: "file://BOT-anist_video.mov")!,
            imageName: "landing",
            yearOfRelease: 2024,
            duration: 66,
            contentRating: "NR",
            isFeatured: true
        ),
        
        Video(
            id: 2,
            name: "Seed Sampling",
            synopsis: """
                On a planet covered in lush jungles and thriving vegetation there’s bound to be some unique plants out there, \
                and the robot botanist is on a mission to find and catalog them all. But as the botanist explores this new planet, \
                it comes to discover more than just new plants.
                """,
            categoryIDs: [
                1001,
                1004,
                1005
            ],
            url: URL(string: "file://BOT-anist_video.mov")!,
            imageName: "samples",
            yearOfRelease: 2024,
            duration: 66,
            startTime: 21,
            contentRating: "NR",
            isFeatured: true
        ),
        
        Video(
            id: 3,
            name: "The Lab",
            synopsis: """
                After filling its backpack to the brim with dozens of plant samples, it’s time for the robot botanist to return to the lab \
                and learn more about these mysterious alien plants. Hours of demanding research lie ahead as the botanist gets to work.
                """,
            categoryIDs: [
                1004,
                1005
            ],
            url: URL(string: "file://BOT-anist_video.mov")!,
            imageName: "lab",
            yearOfRelease: 2024,
            duration: 66,
            startTime: 35,
            contentRating: "NR",
            isFeatured: true
        ),
        
        Video(
            id: 4,
            name: "Discovering",
            synopsis: """
                Always determined to discover new species of plants, the robot botanist explores further and further. Eventually, \
                its mission brings it deep below the planet’s surface into a vast network of underground caves. \
                Though the terrain may become challenging for a robot, the botanist pushes on.
                """,
            categoryIDs: [
                1004,
                1005
            ],
            url: URL(string: "file://BOT-anist_video.mov")!,
            imageName: "discovery",
            yearOfRelease: 2024,
            duration: 66,
            startTime: 51,
            contentRating: "NR",
            isFeatured: true
        ),
        
        Video(
            id: 5,
            name: "Dance",
            synopsis: """
                Everyone needs a break from work sometimes, even the trusty robot botanist. \
                Take a beat and unwind while the robot botanist breaks out its best dance moves during an impromptu dance party.
                """,
            categoryIDs: [
                1004
            ],
            url: URL(string: "file://dance_video.mov")!,
            imageName: "dance",
            yearOfRelease: 2024,
            duration: 16,
            contentRating: "NR",
            isFeatured: true
        ),
        
        Video(
            id: 6,
            name: "A Beach",
            synopsis: """
                From an award-winning producer and actor, ”A Beach” is a sweeping, drama depicting waves crashing on a scenic California beach. \
                Sit back and enjoy the sweet sounds of the ocean while relaxing on a soft, sandy beach.
                """,
            categoryIDs: [
                1002
            ],
            url: URL(string: "https://playgrounds-cdn.apple.com/assets/beach/index.m3u8")!,
            imageName: "beach",
            yearOfRelease: 2023,
            duration: 61,
            contentRating: "NR",
            isFeatured: true
        ),
        
        Video(
            id: 7,
            name: "By the Lake",
            synopsis: """
                The battle for the sunniest spot continues, as a group of turtles take their positions on the log. \
                Find out who the last survivor is, and who swims away cold.
                """,
            categoryIDs: [
                1002,
                1003
            ],
            url: URL(string: "https://playgrounds-cdn.apple.com/assets/lake/index.m3u8")!,
            imageName: "lake",
            yearOfRelease: 2023,
            duration: 19,
            contentRating: "NR"
        ),
        
        Video(
            id: 8,
            name: "Camping in the Woods",
            synopsis: """
                Come along for a journey of epic proportion as the perfect camp site is discovered. \
                Listen to the magical wildlife and feel the gentle breeze of the wind as you watch the daisies dance in the field of flowers.
                """,
            categoryIDs: [
                1001
            ],
            url: URL(string: "https://playgrounds-cdn.apple.com/assets/camping/index.m3u8")!,
            imageName: "camping",
            yearOfRelease: 2023,
            duration: 28,
            contentRating: "NR"
        ),
        
        Video(
            id: 9,
            name: "Birds in the Park",
            synopsis: """
                On a dreamy spring day near the California hillside, some friendly little birds flutter about, \
                hopping from stalk to stalk munching on some tasty seeds. Listen to them chatter as they go about their busy afternoon.
                """,
            categoryIDs: [
                1003
            ],
            url: URL(string: "https://playgrounds-cdn.apple.com/assets/park/index.m3u8")!,
            imageName: "park",
            yearOfRelease: 2023,
            duration: 23,
            contentRating: "NR"
        ),
        
        Video(
            id: 10,
            name: "Mystery at the Creek",
            synopsis: """
                A mystery is brewing on a rainy Wednesday in California, as a couple of friends head to a local campsite for a weekend in the woods. \
                They never anticipated what could be living down by the trickling, rocky creek.
                """,
            categoryIDs: [
                1001,
                1002
            ],
            url: URL(string: "https://playgrounds-cdn.apple.com/assets/creek/index.m3u8")!,
            imageName: "creek",
            yearOfRelease: 2023,
            duration: 28,
            contentRating: "NR"
        ),
        
        Video(
            id: 11,
            name: "The Rolling Hills",
            synopsis: """
                Discover the beauty beyond the highway, just steps away from your normal commute. \
                What lies beyond is a stunning show of delicate fog rolling over the hillside.
                """,
            categoryIDs: [
                1000
            ],
            url: URL(string: "https://playgrounds-cdn.apple.com/assets/hillside/index.m3u8")!,
            imageName: "hillside",
            yearOfRelease: 2023,
            duration: 80,
            contentRating: "NR",
            isFeatured: true
        ),
        
        Video(
            id: 12,
            name: "Ocean Breeze",
            synopsis: """
                Experience the great flight of a black beetle, as it crawls along a giant rock near the lake preparing for takeoff. \
                Where it will go, nobody knows!
                """,
            categoryIDs: [
                1000,
                1002
            ],
            url: URL(string: "https://playgrounds-cdn.apple.com/assets/ocean/index.m3u8")!,
            imageName: "ocean",
            yearOfRelease: 2023,
            duration: 14,
            contentRating: "NR"
        )
    ]
}
