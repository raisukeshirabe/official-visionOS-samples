/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
struct for working with unoredered pairs of the same type.
*/

// Unordered pair of the same type.
struct UnorderedPair <T> {

    let itemA: T
    let itemB: T

    init(_ itemA: T, _ itemB: T) {
        self.itemA = itemA
        self.itemB = itemB
    }
}

extension UnorderedPair {
    func first(where predicate: (T) -> Bool) -> T? {
        predicate(itemA) ? itemA : predicate(itemB) ? itemB : nil
    }

    func either(where predicate: (T) -> Bool) -> Bool {
        predicate(itemA) || predicate(itemB)
    }

    func other(than known: T) -> T? where T: Equatable {
        itemA == known ? itemB : itemB == known ? itemA : nil
    }

    func map <U> (_ transform: (T) -> U) -> UnorderedPair<U> {
        .init(transform(itemA), transform(itemB))
    }
}

extension UnorderedPair: Equatable where T: Equatable {
    // (A,B) == (B,A)
    static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.itemA == rhs.itemA && lhs.itemB == rhs.itemB) || (lhs.itemA == rhs.itemB && lhs.itemB == rhs.itemA)
    }
}

extension UnorderedPair: Hashable where T: Hashable {
    // Provide a hash value such that (A,B) and (B,A) are hashed equivalently.
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemA.hashValue ^ itemB.hashValue)
    }
}

extension UnorderedPair: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        "\(itemA.description)/\(itemB.description)"
    }
}
