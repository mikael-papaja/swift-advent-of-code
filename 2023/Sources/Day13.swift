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
        return entities.map { findReflection($0, isPart2: true) }.reduce(0, +)
    }

    struct Reflection {
        let count: Int
        let value: Int
    }

    private func findReflection(_ input: [String], isPart2: Bool = false) -> Int {
        let part2Input = input.map { Array($0).map { $0 } }
        let horizontal = isPart2 ? findHorizontalReflectionAndFixSmudge(part2Input) : findHorizontalReflection(input)
        let vertical = findVerticalReflection(input, isPart2: isPart2)

        return if horizontal.count >= vertical.count {
            horizontal.value
        } else {
            vertical.value
        }
    }

    private func findHorizontalReflection(_ input: [String], isVertical: Bool = false) -> Reflection {
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
                if secondIndex <= innerIndex {
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

    private func findHorizontalReflectionAndFixSmudge(_ input: [[Character]], isVertical: Bool = false) -> Reflection {
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

            var didFixSmudge = false
            var matches = 0
            for innerIndex in 0 ..< currentheight {
                let secondIndex = currentIndex + (currentheight * 2) - innerIndex - 1
                if secondIndex <= innerIndex {
                    break
                }
                let first = input[currentIndex + innerIndex]
                let second = input[secondIndex]

                var isValid = true
                for characterIndex in 0 ..< first.count {
                    if first[characterIndex] != second[characterIndex] {
                        if !didFixSmudge {
                            didFixSmudge = true
                        } else {
                            isValid = false
                            break
                        }
                    }
                }

                if isValid {
                    matches += 1
                } else {
                    break
                }
            }

            // The reflection needs to reach one of the edges to be valid and smudge must be fixed
            if matches == currentheight && didFixSmudge && (currentIndex == 0 || currentIndex + currentheight * 2 == height) {
                return if isVertical {
                    Reflection(count: currentheight, value: currentIndex + currentheight)
                } else {
                    Reflection(count: currentheight, value: (currentIndex + currentheight) * 100)
                }
            }

            currentIndex += 1
        }
    }

    private func findVerticalReflection(_ input: [String], isPart2: Bool = false) -> Reflection {
        let input = input.map { Array($0).map { $0 } }
        var newInput = [String]()
        var part2Input = [[Character]]()
        for x in 0 ..< input[0].count {
            var newString = ""
            var part2Row = [Character]()
            for y in 0 ..< input.count {
                newString += "\(input[y][x])"
                part2Row.append(input[y][x])
            }
            newInput.append(newString)
            part2Input.append(part2Row)
        }

        return isPart2 ? findHorizontalReflectionAndFixSmudge(part2Input, isVertical: true) : findHorizontalReflection(newInput, isVertical: true)
    }
}
