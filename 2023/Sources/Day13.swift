import Algorithms
import Foundation

struct Day13: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[String]] {
        data.split(separator: "\n\n").map {
            $0.split(separator: "\n").compactMap { "\($0)" }
        }
    }

    func part1() -> Any {
        return entities.map { findReflection($0) }.reduce(0, +)
    }

    func part2() -> Any {
        return 0
    }

    struct Reflection {
        let count: Int
        let value: Int
    }

    func findReflection(_ input: [String]) -> Int {
        let horizontal = findHorizontalReflection(input)
        let vertical = findVerticalReflection(input)

        print("\n\(input.joined(separator: "\n"))")
        print("horizontal: \(horizontal)")
        print("vertical: \(vertical)")

        // return horizontal.value + vertical.value

        return if horizontal.count >= vertical.count {
            horizontal.value
        } else {
            vertical.value
        }
    }

    func findHorizontalReflection(_ input: [String], isVertical: Bool = false) -> Reflection {
        let height = input.count

        var currentheight = height / 2
        var currentIndex = 0
        while true {
            if currentheight == 0 {
                return Reflection(count: 0, value: 0)
            }
            if currentIndex + (currentheight * 2) > height {
                currentheight -= 1
                currentIndex = 0
                continue
            }

            var matches = 0
            for innerIndex in 0 ..< currentheight {
                let secondIndex = currentIndex + (currentheight * 2) - innerIndex - 1
                if secondIndex <= innerIndex  {
                    break
                }
                let first = input[currentIndex + innerIndex]
                let second = input[secondIndex]
                if first == second {
                    matches += 1
                } else {
                    break
                }
            }

            // The reflection needs to reach one of the edges to be valid
            if matches == currentheight && (currentIndex == 0 || currentIndex + currentheight * 2 == height) {
                return if isVertical {
                    Reflection(count: currentheight, value: currentIndex + currentheight)
                } else {
                    Reflection(count: currentheight, value: (currentIndex + currentheight) * 100)
                }
            }

            currentIndex += 1
        }
    }

    func findVerticalReflection(_ input: [String]) -> Reflection {
        let input = input.map { Array($0).map { $0 } }
        var newInput = [String]()
        for x in 0 ..< input[0].count {
            var newString = ""
            for y in 0 ..< input.count {
                newString += "\(input[y][x])"
            }
            newInput.append(newString)
        }

        return findHorizontalReflection(newInput, isVertical: true)
    }
}
