import Algorithms
import Foundation

struct Day08: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    enum Direction: Character, CaseIterable {
        case left = "L"
        case right = "R"

        static func fromValue(from input: Character?) -> Direction? {
            return Direction.allCases.first { $0.rawValue == input }
        }
    }

    struct Path: Equatable {
        let value: String
        let lastValue: Character
        let left: Int
        let right: Int

        static func == (lhs: Path, rhs: Path) -> Bool {
            return lhs.value == rhs.value
        }
    }

    struct Instruction {
        let directions: [Direction]
        let paths: [Path]

        func getStepCount() -> Int {
            guard var currentPath = paths.first(where: { $0.value == "AAA" }) else {
                return 0
            }

            var stepCount = 0
            var currentIndex = 0

            while true {
                currentPath = directions[currentIndex] == .left ? paths[currentPath.left] : paths[currentPath.right]
                currentIndex = (currentIndex + 1) % directions.count
                stepCount += 1

                if currentPath.value == "ZZZ" {
                    return stepCount
                }
            }
        }

        func getGhostStepCount() -> Int {
            var stepCount = 0
            var currentPathIndexes = [Int]()
            var currentDirectionIndex = 0
            var goalCounts = [Int]()

            for path in paths where path.lastValue == "A" {
                guard let index = paths.firstIndex(where: { $0 == path }) else {
                    return 0
                }

                currentPathIndexes.append(index)
            }

            while !currentPathIndexes.isEmpty {
                let currentDirection = directions[currentDirectionIndex]
                var nextIndexes = [Int]()

                for currentPathIndex in currentPathIndexes {
                    let path = paths[currentPathIndex]
                    let nextIndex = currentDirection == .left ? path.left : path.right

                    if paths[nextIndex].lastValue == "Z" {
                        goalCounts.append(stepCount + 1)
                        continue
                    }

                    nextIndexes.append(nextIndex)
                }

                currentPathIndexes = nextIndexes
                currentDirectionIndex = (currentDirectionIndex + 1) % directions.count
                stepCount += 1
            }

            return lcmm(goalCounts)
        }

        // Euclid's algorithm for finding the greatest common divisor
        private func gcd(_ a: Int, _ b: Int) -> Int {
            let remainder = a % b
            if remainder != 0 {
                return gcd(b, remainder)
            } else {
                return b
            }
        }

        // Returns the least common multiple of two numbers.
        private func lcm(_ m: Int, _ n: Int) -> Int {
            return m / gcd(m, n) * n
        }

        // Returns the least common multiple of multiple numbers.
        private func lcmm(_ numbers: [Int]) -> Int {
            return numbers.reduce(1) { lcm($0, $1) }
        }

        static func initFromInputs(_ inputs: [String]) -> Instruction? {
            let regex = "([^A-Z\\d])+"
            var inputs = inputs
            var didSetDirections = false
            var directions = [Direction]()
            var paths: [String: (left: String, right: String)] = [:]
            var indexedPaths = [String]()

            while !inputs.isEmpty {
                let input = inputs.removeFirst()

                if !didSetDirections {
                    directions = input.compactMap { Direction.fromValue(from: $0) }
                    didSetDirections = true
                    continue
                }

                let pathStrings = input
                    .replacingOccurrences(of: regex, with: "", options: .regularExpression, range: nil)
                    .evenlyChunked(in: 3)
                    .map { String($0) }
                guard pathStrings.count == 3, pathStrings[0].count == 3, pathStrings[1].count == 3, pathStrings[2].count == 3 else {
                    return nil
                }

                paths[pathStrings[0]] = (left: pathStrings[1], right: pathStrings[2])
                indexedPaths.append(pathStrings[0])
            }

            var paths2: [Path] = Array(repeating: Path(value: "", lastValue: "*", left: 0, right: 0), count: indexedPaths.count)
            for path in paths {
                guard let index = indexedPaths.firstIndex(of: path.key),
                      let leftIndex = indexedPaths.firstIndex(of: path.value.left),
                      let rightIndex = indexedPaths.firstIndex(of: path.value.right)
                else {
                    return nil
                }

                paths2[index] = Path(value: path.key, lastValue: path.key.last!, left: leftIndex, right: rightIndex)
            }

            if paths2.contains(where: { $0.lastValue == "*" }) {
                return nil
            }

            return Instruction(directions: directions, paths: paths2)
        }
    }

    func part1() -> Any {
        return Instruction.initFromInputs(entities)?.getStepCount() ?? 0
    }

    func part2() -> Any {
        return Instruction.initFromInputs(entities)?.getGhostStepCount() ?? 0
    }
}
