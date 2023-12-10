import Algorithms
import Foundation

struct Day01: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[Int]] {
        data.split(separator: "\n\n").map {
            $0.split(separator: "\n").compactMap { Int($0) }
        }
    }

    func part1() -> Any {
        return entities.map { $0.reduce(0, +) }.max() ?? 0
    }

    func part2() -> Any {
        return entities.map { $0.reduce(0, +) }.sorted().reversed()[0 ... 2].reduce(0, +)
    }
}
