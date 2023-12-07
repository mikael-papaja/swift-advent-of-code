//
import Algorithms
import Foundation

struct Day01: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    func part1() -> Any {
        return entities.map { getIntValue($0) }.reduce(0, +)
    }

    func part2() -> Any {
        return entities.map { getIntValue(replaceValuesInString($0)) }.reduce(0, +)
    }

    // Get first and last number in string and return as Int
    private func getIntValue(_ input: String) -> Int {
        // Remove all non digits and split into array
        let values = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().map { "\($0)" }
        guard let first = values.first, let last = values.last else { return 0 }
        return Int("\(first)\(last)") ?? 0
    }

    // Find all number words in string and insert number value at starting index of found word
    private func replaceValuesInString(_ input: String) -> String {
        var returnString = input
        var foundValues = [(index: Int, value: Int)]()
        let rangevalues: [String] = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine",]
        for (index, value) in rangevalues.enumerated() {
            var searchStartIndex = input.startIndex

            // While loop is needed so multiple instances of a word can be found
            while searchStartIndex < input.endIndex,
                  let range = input.range(of: value, range: searchStartIndex ..< input.endIndex),
                  !range.isEmpty
            {
                let startIndex = input.distance(from: input.startIndex, to: range.lowerBound)
                foundValues.append((startIndex, index + 1))
                searchStartIndex = range.upperBound
            }
        }

        // Sort found values by index and insert number value at index
        let sortedValues = foundValues.sorted { $0.index < $1.index }
        for (index, value) in sortedValues.enumerated() {
            returnString.insert(contentsOf: "\(value.value)", at: returnString.index(returnString.startIndex, offsetBy: value.index + index))
        }

        return returnString
    }
}
