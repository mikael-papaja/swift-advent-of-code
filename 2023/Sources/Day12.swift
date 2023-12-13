import Algorithms
import Foundation

struct Day12: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    enum RecordType: Character {
        case operational = "."
        case damaged = "#"
        case unknown = "?"
    }

    struct Arrangement: Hashable {
        let types: [RecordType]
        let startingIndex: Int
    }

    struct Record {
        let types: [RecordType]
        let conditions: [Int]

        func getArrangementCount() -> Int {
            // TODO: Understand this
            var coordinateValues = [Coordinate: Int]()
            coordinateValues[Coordinate(x: 0, y: 0)] = 1
            for index in 0 ..< types.count {
                var innerCoordinateValues = [Coordinate: Int]()
                var possibleTypes = [types[index]]
                if types[index] == .unknown {
                    possibleTypes = [.operational, .damaged]
                }
                for coordinateValue in coordinateValues {
                    let x = coordinateValue.key.x
                    let y = coordinateValue.key.y
                    for type in possibleTypes {
                        if x == conditions.count {
                            if type == .operational {
                                let currentValue = innerCoordinateValues[Coordinate(x: x, y: y)] ?? 0
                                innerCoordinateValues[Coordinate(x: x, y: y)] = currentValue + coordinateValue.value
                            }
                        } else {
                            if y == conditions[x] {
                                if type == .operational {
                                    let currentValue = innerCoordinateValues[Coordinate(x: x + 1, y: 0)] ?? 0
                                    innerCoordinateValues[Coordinate(x: x + 1, y: 0)] = currentValue + coordinateValue.value
                                }
                            } else {
                                if type == .operational && y == 0 {
                                    let currentValue = innerCoordinateValues[Coordinate(x: x, y: y)] ?? 0
                                    innerCoordinateValues[Coordinate(x: x, y: y)] = currentValue + coordinateValue.value
                                }
                                if type == .damaged {
                                    let currentValue = innerCoordinateValues[Coordinate(x: x, y: y + 1)] ?? 0
                                    innerCoordinateValues[Coordinate(x: x, y: y + 1)] = currentValue + coordinateValue.value
                                }
                            }
                        }
                    }
                }

                coordinateValues = innerCoordinateValues
            }

            let hej = coordinateValues[Coordinate(x: conditions.count, y: 0)] ?? 0
            let dig = coordinateValues[Coordinate(x: conditions.count - 1, y: conditions.last!)] ?? 0
            return hej + dig
        }

        static func initFromString(_ input: String, unfolded: Bool) -> Record? {
            let data = input.split(separator: " ").compactMap { "\($0)" }
            if data.count != 2 {
                return nil
            }
            let types = data[0].map { RecordType(rawValue: $0) ?? .unknown }
            let conditions = data[1].split(separator: ",").compactMap { Int("\($0)") }
            if !unfolded {
                return Record(types: types, conditions: conditions)
            }

            var unfoldedTypes = types
            var unfoldedConditions = conditions
            for _ in 0 ..< 4 {
                unfoldedTypes.append(.unknown)
                unfoldedTypes.append(contentsOf: types)
                unfoldedConditions.append(contentsOf: conditions)
            }

            return Record(types: unfoldedTypes, conditions: unfoldedConditions)
        }
    }

    struct Coordinate: Hashable {
        let x: Int
        let y: Int
    }

    func part1() -> Any {
        guard let records = getRecords() else {
            return 0
        }

        return getArrangementCounts(records).reduce(0, +)
    }

    func part2() -> Any {
        guard let records = getRecords(unfolded: true) else {
            return 0
        }

        return getArrangementCounts(records).reduce(0, +)
    }

    private func getRecords(unfolded: Bool = false) -> [Record]? {
        let records = entities.compactMap { Record.initFromString($0, unfolded: unfolded) }
        if records.count != entities.count {
            return nil
        }

        return records
    }

    private func getArrangementCounts(_ records: [Record]) -> [Int] {
        return records.map { $0.getArrangementCount() }
    }
}
