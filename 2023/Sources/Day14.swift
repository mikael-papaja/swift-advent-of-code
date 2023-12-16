import Algorithms
import Foundation

struct Day14: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[Character]] {
        data.components(separatedBy: "\n").compactMap { $0.isEmpty ? nil : Array($0) }
    }

    struct DirectionValues: Hashable {
        let north: [[Character]]
        let west: [[Character]]
        let south: [[Character]]
        let east: [[Character]]

        static func == (lhs: DirectionValues, rhs: DirectionValues) -> Bool {
            return lhs.north == rhs.north && lhs.west == rhs.west && lhs.south == rhs.south && lhs.east == rhs.east
        }
    }

    class CycleCounter {
        var isValid: Bool = true
        var cycles: [Int] = []
        var nextValue: DirectionValues?
    }

    func part1() -> Any {
        return calculateTotalLoad(rollNorth())
    }

    func part2() -> Any {
        return calculateTotalLoad(performCycles())
    }

    func performCycles() -> [[Character]] {
        let cycles = 1_000_000_000
        var data = entities
        var previousValues = [DirectionValues: CycleCounter]()
        var previousValue: DirectionValues?
        for index in 0 ..< cycles {
            if let value = previousValue, previousValues[value]?.isValid == false {
                previousValue = previousValues[value]!.nextValue
                continue
            }
            let north = rollNorth(data: data)
            let west = rollWest(north)
            let south = rollSouth(west)
            let east = rollEast(south)
            let currentValue = DirectionValues(north: north, west: west, south: south, east: east)
            guard let prev = previousValue else {
                previousValue = currentValue
                continue
            }

            if previousValues[prev] == nil {
                let counter = CycleCounter()
                counter.cycles = [index]
                counter.nextValue = currentValue
                previousValues[prev] = counter
            } else {
                previousValues[prev]?.cycles.append(index)
            }

            if previousValues[prev]!.cycles.count > 2 {
                let valueCycles = previousValues[prev]!.cycles
                var previousCycleValue = valueCycles[0]
                var differences: [Int] = []
                for i in 1 ..< valueCycles.count {
                    differences.append(valueCycles[i] - previousCycleValue)
                    previousCycleValue = valueCycles[i]
                }

                if differences.allSatisfy({ $0 == differences[0] }) {
                    if (cycles - index) % differences[0] == 0 {
                        return east
                    } else {
                        previousValues[prev]!.isValid = false
                    }
                }
            }

            previousValue = currentValue
            data = east
        }

        return data
    }

    private func rollNorth(data: [[Character]]? = nil) -> [[Character]] {
        var data = data ?? entities

        var currentRow = 0
        var lowestFreeIndex: [Int] = Array(repeating: 0, count: entities[0].count)
        while currentRow < entities.count {
            for (index, character) in data[currentRow].enumerated() {
                if character == "#" {
                    lowestFreeIndex[index] = currentRow + 1
                } else if character == "O" {
                    if lowestFreeIndex[index] < currentRow {
                        data[currentRow][index] = "."
                        data[lowestFreeIndex[index]][index] = "O"
                        lowestFreeIndex[index] += 1
                    } else {
                        lowestFreeIndex[index] = currentRow + 1
                    }
                }
            }

            currentRow += 1
        }

        return data
    }

    private func rollWest(_ data: [[Character]]) -> [[Character]] {
        let data = rollNorth(data: getRotatedData(data))
        return getRotatedData(data)
    }

    private func rollSouth(_ data: [[Character]]) -> [[Character]] {
        return rollNorth(data: Array(data.reversed())).reversed()
    }

    private func rollEast(_ data: [[Character]]) -> [[Character]] {
        let data = rollNorth(data: getRotatedData(data).reversed())
        return getRotatedData(data.reversed())
    }

    private func getRotatedData(_ data: [[Character]]) -> [[Character]] {
        var rotatedData = [[Character]]()
        for x in 0 ..< data[0].count {
            var row = [Character]()
            for y in 0 ..< data.count {
                row.append(data[y][x])
            }
            rotatedData.append(row)
        }

        return rotatedData
    }

    private func calculateTotalLoad(_ input: [[Character]]) -> Int {
        var totalLoad = 0
        for (index, row) in input.enumerated() {
            totalLoad += row.filter { $0 == "O" }.count * (input.count - index)
        }

        return totalLoad
    }
}
