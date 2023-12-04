//
//  Day03.swift
//
//
//  Created by Mikael Bergman on 2023-12-01.
//

import Algorithms
import Foundation

struct Day03: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    enum ValueType {
        case number
        case symbol
        case gear
        case nothing

        static func getValueType(_ char: Character) -> ValueType {
            return if char.isWholeNumber {
                .number
            } else if char == "." {
                .nothing
            } else if char == "*" {
                .gear
            } else {
                .symbol
            }
        }
    }

    struct Point: Equatable, CustomStringConvertible {
        let x: Int
        let y: Int

        public var description: String {
            return "(\(x), \(y))"
        }

        static func == (lhs: Day03.Point, rhs: Day03.Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
    }

    struct Number: Equatable, CustomStringConvertible {
        let value: Int
        let points: [Point]

        public var description: String {
            return "\(value) at \(points)"
        }

        static func == (lhs: Day03.Number, rhs: Day03.Number) -> Bool {
            if lhs.value != rhs.value {
                return false
            }

            for lhsPoint in lhs.points {
                if !rhs.points.contains(lhsPoint) {
                    return false
                }
            }

            return true
        }
    }

    struct ValueTypePoint: CustomStringConvertible {
        let type: ValueType
        let point: Point

        public var description: String {
            return "\(type) at \(point)"
        }
    }

    struct NumbersAndSymbols: CustomStringConvertible {
        let numbers: [Number]
        let symbols: [ValueTypePoint]

        public var description: String {
            return "Numbers: \(numbers)\nSymbols: \(symbols)"
        }
    }

    func part1() -> Any {
        let numbersAndSymbols = getNumberAndSymbols()
        let symbolPoints = numbersAndSymbols.symbols.map { $0.point }
        return numbersAndSymbols.numbers
            .filter { hasNearbySymbol($0, symbols: symbolPoints) }
            .map { $0.value }
            .reduce(0, +)
    }

    func part2() -> Any {
        return getSumOfMultiples(getNumberAndSymbols())
    }

    // Get numbers with their coordinates, and symbols with their coordinate.
    private func getNumberAndSymbols() -> NumbersAndSymbols {
        var numbers = [Number]()
        var symbols = [ValueTypePoint]()

        for (y, entity) in entities.enumerated() {
            var currentNumber = ""
            var currentPoints = [Point]()

            for (x, char) in entity.enumerated() {
                let type = ValueType.getValueType(char)
                switch type {
                case .number:
                    currentNumber += String(char)
                    currentPoints.append(Point(x: x, y: y))
                    continue
                case .gear, .symbol:
                    symbols.append(ValueTypePoint(type: type, point: Point(x: x, y: y)))
                case .nothing:
                    break
                }

                if currentNumber != "" && !currentPoints.isEmpty {
                    numbers.append(Number(value: Int(currentNumber)!, points: currentPoints))
                    currentNumber = ""
                    currentPoints = []
                }
            }

            if currentNumber != "" {
                numbers.append(Number(value: Int(currentNumber)!, points: currentPoints))
            }
        }

        return NumbersAndSymbols(numbers: numbers, symbols: symbols)
    }

    // Return true if a number is next to a symbol
    private func hasNearbySymbol(_ number: Number, symbols: [Point]) -> Bool {
        guard let numberY = number.points.first?.y else {
            return false
        }
        let numberXs = number.points.map { $0.x }
        let nearbyRows = symbols.filter { [numberY - 1, numberY, numberY + 1].contains($0.y) }
        for point in nearbyRows {
            if point.y == numberY && (point.x == (numberXs.min()! - 1) || point.x == (numberXs.max()! + 1)) {
                return true
            }
            if point.y == numberY {
                continue
            }
            if ((numberXs.min()! - 1) ... (numberXs.max()! + 1)).contains(point.x) {
                return true
            }
        }
        return false
    }

    // Return the sum of all numbers that are a multiple of two numbers that are next to a gear (*) symbol
    private func getSumOfMultiples(_ numbersAndSymbols: NumbersAndSymbols) -> Int {
        var numbers = numbersAndSymbols.numbers
        let gears = numbersAndSymbols.symbols.filter { $0.type == .gear }
        var products = [(Int, Int)]()

        for gear in gears {
            var gearNumbers = [Number]()
            var yNumbers = numbers.filter { $0.points.first!.y == (gear.point.y - 1) }
            yNumbers += numbers.filter { $0.points.first!.y == (gear.point.y + 1) }
            for number in yNumbers {
                if ((number.points.map { $0.x }.min()! - 1) ... (number.points.map { $0.x }.max()! + 1)).contains(gear.point.x) {
                    gearNumbers.append(number)
                }
            }

            let xNumbers = numbers.filter { $0.points.first!.y == gear.point.y }
            for number in xNumbers {
                if gear.point.x == (number.points.map { $0.x }.min()! - 1) || gear.point.x == (number.points.map { $0.x }.max()! + 1) {
                    gearNumbers.append(number)
                }
            }

            if gearNumbers.count != 2 {
                continue
            }

            products.append((gearNumbers[0].value, gearNumbers[1].value))
            if let index = numbers.firstIndex(of: gearNumbers[0]) {
                numbers.remove(at: index)
            }
            if let index = numbers.firstIndex(of: gearNumbers[1]) {
                numbers.remove(at: index)
            }
        }

        return products.map { $0.0 * $0.1 }.reduce(0, +)
    }
}
