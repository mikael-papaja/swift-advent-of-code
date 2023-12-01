//
//  Day01.swift
//
//
//  Created by Mikael Bergman on 2023-12-01.
//

import Algorithms
import Foundation

struct Day01: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap {
            "\($0)"
        }
    }

    func part1() -> Any {
        return entities.map { entity in
            getIntValue(entity)
        }.reduce(0, +)
    }

    func part2() -> Any {
        return entities.map { entity in
            getIntValue(replaceValuesInString(entity))
        }.reduce(0, +)
    }

    private func getIntValue(_ input: String) -> Int {
        let values = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().map { "\($0)" }
        guard let first = values.first, let last = values.last else { return 0 }
        return Int("\(first)\(last)") ?? 0
    }

    private func replaceValuesInString(_ input: String) -> String {
        var returnString = input
        var foundValues = [(index: Int, value: Int)]()
        let rangevalues: [(String, Int)] = [
            ("one", 1),
            ("two", 2),
            ("three", 3),
            ("four", 4),
            ("five", 5),
            ("six", 6),
            ("seven", 7),
            ("eight", 8),
            ("nine", 9)
        ]
        for value in rangevalues {
            var searchStartIndex = input.startIndex
            while searchStartIndex < input.endIndex,
                  let range = input.range(of: value.0, range: searchStartIndex ..< input.endIndex),
                  !range.isEmpty
            {
                let index = input.distance(from: input.startIndex, to: range.lowerBound)
                foundValues.append((index, value.1))
                searchStartIndex = range.upperBound
            }
        }
        let sortedValues = foundValues.sorted { $0.index < $1.index }
        for (index, value) in sortedValues.enumerated() {
            returnString.insert(contentsOf: "\(value.value)", at: returnString.index(returnString.startIndex, offsetBy: value.index + index))
        }
        return returnString
    }
}
