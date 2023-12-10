import Algorithms
import Foundation

struct Day03: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[Character]] {
        data.split(separator: "\n").map { Array($0) }
    }

    func part1() -> Any {
        return getLetterValues(getCompartmentDoubles(entities)).reduce(0, +)
    }

    func part2() -> Any {
        return getLetterValues(getGroupBadges(entities)).reduce(0, +)
    }

    private func getCompartmentDoubles(_ inputs: [[Character]]) -> [Character] {
        var doubles = [Character]()
        for input in inputs {
            let halves = input.chunks(ofCount: input.count / 2).map { Array($0) }
            doubles.append(contentsOf: halves[0].filter { halves[1].contains($0) }.uniqued())
        }
        return doubles
    }

    private func getGroupBadges(_ inputs: [[Character]]) -> [Character] {
        let groups = inputs.chunks(ofCount: 3).map { Array($0) }
        var badges = [Character]()
        for group in groups {
            badges.append(contentsOf: group[0].filter { group[1].contains($0) && group[2].contains($0) }.uniqued())
        }
        return badges
    }

    private func getLetterArray() -> [Character] {
        var letters: [Character] = (0 ..< 26).map { Character(UnicodeScalar("a".unicodeScalars.first!.value + $0)!) }
        letters.append(contentsOf: letters.map { Character($0.uppercased()) })
        return letters
    }

    private func getLetterValues(_ characters: [Character]) -> [Int] {
        let letterArray = getLetterArray()
        return characters.map { letterArray.firstIndex(of: $0)! + 1 }
    }
}
