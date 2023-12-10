import Algorithms
import Foundation

struct Day09: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[Int]] {
        data.split(separator: "\n").compactMap { line in
            "\(line)".split(separator: " ").compactMap {
                Int("\($0)")
            }
        }
    }

    func part1() -> Any {
        return entities.map { calculateNewSequenceValue(generateAllZeroSequence($0)) }.reduce(0, +)
    }

    func part2() -> Any {
        return entities.map { calculateOldSequenceValue(generateAllZeroSequence($0)) }.reduce(0, +)
    }

    private func calculateNewSequenceValue(_ inputs: [[Int]]) -> Int {
        var currentNewValue = 0
        for input in inputs.reversed() {
            currentNewValue = (input.last ?? 0) + currentNewValue
        }

        return currentNewValue
    }

    private func calculateOldSequenceValue(_ inputs: [[Int]]) -> Int {
        var currentNewValue = 0
        for input in inputs.reversed() {
            currentNewValue = (input.first ?? 0) - currentNewValue
        }

        return currentNewValue
    }

    private func generateAllZeroSequence(_ input: [Int]) -> [[Int]] {
        var result: [[Int]] = [input]
        var newSequence = [Int]()
        for index in 0 ..< input.count - 1 {
            newSequence.append(input[index + 1] - input[index])
        }

        if newSequence.contains(where: { $0 != 0 }) {
            result.append(contentsOf: generateAllZeroSequence(newSequence))
        }

        return result
    }
}
