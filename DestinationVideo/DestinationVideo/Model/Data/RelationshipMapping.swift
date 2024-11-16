/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The relationship between video, actor, writer, director, and genre.
*/

import Foundation

/// The relationship between video, actor, writer, director ,and genre.
struct RelationshipMapping: Decodable {
    let videoID: Int
    let actorIDs: [Int]
    let writerIDs: [Int]
    let directorIDs: [Int]
    let genreIDs: [Int]
}

extension SampleData {
    @MainActor static let relationships = [
        RelationshipMapping(
            videoID: 0,
            actorIDs: [1, 6],
            writerIDs: [32, 15],
            directorIDs: [4],
            genreIDs: [7, 8]
        ),
        RelationshipMapping(
            videoID: 1,
            actorIDs: [1, 6],
            writerIDs: [32, 15],
            directorIDs: [4],
            genreIDs: [7, 4]
        ),
        RelationshipMapping(
            videoID: 2,
            actorIDs: [1, 6],
            writerIDs: [32, 15],
            directorIDs: [4],
            genreIDs: [7, 8]
        ),
        RelationshipMapping(
            videoID: 3,
            actorIDs: [1, 6],
            writerIDs: [32, 15],
            directorIDs: [4],
            genreIDs: [7, 8]
        ),
        RelationshipMapping(
            videoID: 4,
            actorIDs: [1, 6],
            writerIDs: [32, 15],
            directorIDs: [4],
            genreIDs: [7, 6]
        ),
        RelationshipMapping(
            videoID: 5,
            actorIDs: [20, 23, 11, 16],
            writerIDs: [25, 10],
            directorIDs: [17],
            genreIDs: [2, 7]
            ),
        RelationshipMapping(
            videoID: 6,
            actorIDs: [20, 23, 11, 16],
            writerIDs: [25, 10],
            directorIDs: [17],
            genreIDs: [0, 1]
        ),
        RelationshipMapping(
            videoID: 7,
            actorIDs: [18, 13],
            writerIDs: [33],
            directorIDs: [5],
            genreIDs: [2, 3]
            ),
        RelationshipMapping(
            videoID: 8,
            actorIDs: [27, 7, 2],
            writerIDs: [28],
            directorIDs: [21],
            genreIDs: [3, 4]
        ),
        RelationshipMapping(
            videoID: 9,
            actorIDs: [3, 24],
            writerIDs: [8, 0],
            directorIDs: [26, 31],
            genreIDs: [5]
        ),
        RelationshipMapping(
            videoID: 10,
            actorIDs: [22, 30],
            writerIDs: [9],
            directorIDs: [19, 12],
            genreIDs: [6]
            ),
        RelationshipMapping(
            videoID: 11,
            actorIDs: [14, 24],
            writerIDs: [0],
            directorIDs: [29],
            genreIDs: [1, 0]
        ),
        RelationshipMapping(
            videoID: 12,
            actorIDs: [1, 6],
            writerIDs: [32, 15],
            directorIDs: [4],
            genreIDs: [2, 3]
        )
    ]
}
