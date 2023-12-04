//
//  Day02.swift
//
//
//  Created by Mikael Bergman on 2023-12-01.
//

import Algorithms
import Foundation

struct Day02: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    func part1() -> Any {
        var validGameIds: [Int] = []
        for entity in entities {
            let nonWhitespace = entity.replacingOccurrences(of: " ", with: "")
            let game = getGameStringAndGameId(nonWhitespace)
            guard let gameId = game.id else {
                continue
            }

            if isGameValid(nonWhitespace.replacingOccurrences(of: game.string, with: "")) {
                validGameIds.append(gameId)
            }
        }

        return validGameIds.reduce(0, +)
    }

    func part2() -> Any {
        var powers: [Int] = []
        for entity in entities {
            let nonWhitespace = entity.replacingOccurrences(of: " ", with: "")
            let game = getGameStringAndGameId(nonWhitespace)
            if game.id == nil {
                continue
            }

            powers.append(getPowerOfGame(nonWhitespace.replacingOccurrences(of: game.string, with: "")))
        }

        return powers.reduce(0, +)
    }

    // Parse the beginning of the input to get the game string and the game id.
    private func getGameStringAndGameId(_ input: String) -> (string: String, id: Int?) {
        var gameString = ""

        for i in 0 ..< input.count {
            let prefix = input.prefix(i)
            if prefix.last == ":" {
                gameString = String(prefix)
                break
            }
        }

        let gameId = gameString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return (gameString, Int(gameId))
    }

    // Loop through each cubeto make sure their color values are lower than the max allowed values
    private func isGameValid(_ input: String) -> Bool {
        let cubeSets = getCubeSets(input)
        let maxValues: [String: Int] = [
            "red": 12,
            "green": 13,
            "blue": 14
        ]

        for cubeSet in cubeSets {
            for cube in cubeSet {
                let color = cube.components(separatedBy: .letters.inverted).joined()
                let value = cube.components(separatedBy: .decimalDigits.inverted).joined()
                if let maxValue = maxValues[color], let intValue = Int(value), intValue > maxValue {
                    return false
                }
            }
        }

        return true
    }

    // Loop through each cube to get the lowest possible color amount for all sets, then return the power of all colors
    private func getPowerOfGame(_ input: String) -> Int {
        let cubeSets = getCubeSets(input)
        var lowestPossibleValues: [String: Int] = [
            "red": 0,
            "green": 0,
            "blue": 0
        ]

        for cubeSet in cubeSets {
            for cube in cubeSet {
                let color = cube.components(separatedBy: .letters.inverted).joined()
                let value = cube.components(separatedBy: .decimalDigits.inverted).joined()
                if let currentLowest = lowestPossibleValues[color], let intValue = Int(value), intValue > currentLowest {
                    lowestPossibleValues[color] = intValue
                }
            }
        }

        return lowestPossibleValues.values.reduce(1, *)
    }

    private func getCubeSets(_ input: String) -> [[String]] {
        return input
            .split(separator: ";")
            .map { cubeSet in
                "\(cubeSet)".split(separator: ",")
                    .map { "\($0)" }
            }
    }
}
