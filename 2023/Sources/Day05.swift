import Algorithms
import Foundation

struct Day05: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[String]] {
        data.split(separator: "\n\n").map {
            $0.split(separator: "\n").map { "\($0)" }
        }
    }

    enum StepType: String, CaseIterable {
        case seed
        case soil
        case fertilizer
        case water
        case light
        case temperature
        case humidity
        case location

        static func getType(from input: String?) -> StepType? {
            return StepType.allCases.first { $0.rawValue == input }
        }

        static func getTypePair(_ input: String?) -> (from: StepType, to: StepType)? {
            guard let input = input else {
                return nil
            }

            let inputs = input.replacingOccurrences(of: " map:", with: "").split(separator: "-").map { "\($0)" }
            guard inputs.count == 3, let from = StepType.getType(from: inputs.first), let to = StepType.getType(from: inputs.last) else {
                return nil
            }

            return (from, to)
        }
    }

    struct StepRange: Equatable {
        let from: Int
        let to: Int

        static func == (lhs: Day05.StepRange, rhs: Day05.StepRange) -> Bool {
            return lhs.from == rhs.from && lhs.to == rhs.to
        }
    }

    struct Step {
        let source: StepType
        let destination: StepType
        let sourceRanges: [StepRange]
        let destinationRanges: [StepRange]

        func getDestinationValues(fromSourceValues sourceValues: [Int]?) -> [Int]? {
            guard let sourceValues = sourceValues, !sourceValues.isEmpty else {
                return nil
            }

            var destinationValues = [Int]()
            for sourceValue in sourceValues {
                var destinationValue: (Int, Int)?
                for (index, sourceRange) in sourceRanges.enumerated() {
                    if sourceValue < sourceRange.from || sourceValue >= sourceRange.to {
                        continue
                    }

                    destinationValue = (index, sourceValue - sourceRange.from)
                    break
                }

                guard let destinationValue = destinationValue else {
                    destinationValues.append(sourceValue)
                    continue
                }

                destinationValues.append(destinationRanges[destinationValue.0].from + destinationValue.1)
            }

            return destinationValues.isEmpty ? nil : Array(destinationValues.uniqued())
        }

        static func initFromString(typePair: (from: StepType, to: StepType), inputs: [String]) -> Step? {
            var sourceRanges = [StepRange]()
            var destinationRanges = [StepRange]()
            for input in inputs {
                let values = input.trimmingCharacters(in: .whitespaces).split(separator: " ").compactMap { Int($0) }
                guard values.count == 3 else {
                    continue
                }

                sourceRanges.append(StepRange(from: values[1], to: values[1] + values[2]))
                destinationRanges.append(StepRange(from: values[0], to: values[0] + values[2]))
            }

            if sourceRanges.isEmpty || destinationRanges.isEmpty {
                return nil
            }

            return Step(source: typePair.from, destination: typePair.to, sourceRanges: sourceRanges, destinationRanges: destinationRanges)
        }
    }

    func part1() -> Any {
        guard let seeds = getSeeds(entities.first?.first), !seeds.isEmpty else {
            return -1
        }

        return getLocationValues(steps: getSteps(Array(entities.dropFirst())), seeds: seeds)
    }

    func part2() -> Any {
        guard let seedRanges = getSeedRanges(entities.first?.first), !seedRanges.isEmpty else {
            return Int.max
        }
        let filteredRanges = getFilteredRanges(seedRanges)
        let steps = getSteps(Array(entities.dropFirst()))

        var lowest = Int.max
        for seedRange in filteredRanges {
            var currentIndex = 0
            while true {
                guard let currentArray = batchGetArrayFromRange(seedRange, index: currentIndex) else {
                    break
                }

                let currentLow = getLocationValues(steps: steps, seeds: currentArray)
                if currentLow < lowest {
                    lowest = currentLow
                }
                currentIndex += 1
            }
        }

        return lowest
    }

    private func getFilteredRanges(_ ranges: [StepRange]) -> [StepRange] {
        var filteredRanges = [StepRange]()
        var indexesToIgnore = [Int]()
        for index in 0 ..< ranges.count {
            if indexesToIgnore.contains(index) {
                continue
            }

            let current = ranges[index]
            for (innerIndex, innerRange) in ranges.enumerated() {
                if index == innerIndex || indexesToIgnore.contains(innerIndex) {
                    continue
                }

                if current.from <= innerRange.from && current.to >= innerRange.to {
                    indexesToIgnore.append(innerIndex)
                } else if current.from >= innerRange.from && current.to <= innerRange.to {
                    indexesToIgnore.append(index)
                } else if current.from < innerRange.to && current.to > innerRange.to {
                    filteredRanges.append(StepRange(from: innerRange.from, to: current.to))
                    indexesToIgnore.append(innerIndex)
                    indexesToIgnore.append(index)
                } else if current.from < innerRange.from && current.to > innerRange.from {
                    filteredRanges.append(StepRange(from: current.from, to: innerRange.to))
                    indexesToIgnore.append(innerIndex)
                    indexesToIgnore.append(index)
                }
            }

            if !indexesToIgnore.contains(index) {
                filteredRanges.append(current)
                indexesToIgnore.append(index)
            }
        }

        return filteredRanges
    }

    private func getSeeds(_ input: String?) -> [Int]? {
        if let seedEntity = input?.replacingOccurrences(of: "seeds: ", with: "").trimmingCharacters(in: .whitespaces) {
            return seedEntity.split(separator: " ").compactMap { Int("\($0)") }
        }

        return nil
    }

    private func getSeedRanges(_ input: String?) -> [StepRange]? {
        if let seedEntity = input?.replacingOccurrences(of: "seeds: ", with: "").trimmingCharacters(in: .whitespaces) {
            let seedArray = seedEntity.split(separator: " ").compactMap { Int("\($0)") }
            var returnSeeds = [StepRange]()
            for (index, seed) in seedArray.enumerated() {
                if index == 0 || index % 2 == 0 {
                    continue
                }

                returnSeeds.append(StepRange(from: seedArray[index - 1], to: seed + seedArray[index - 1]))
            }

            return returnSeeds
        }

        return nil
    }

    private func batchGetArrayFromRange(_ range: StepRange, index: Int) -> [Int]? {
        let batchSize = 500000
        let currentRange = StepRange(from: range.from + (batchSize * index), to: range.from + (batchSize * (index + 1)))
        
        if currentRange.from >= range.to {
            return nil
        }

        if currentRange.to > range.to {
            return Array(currentRange.from ..< range.to)
        }

        return Array(currentRange.from ..< currentRange.to)
    }

    private func getSteps(_ entities: [[String]]) -> [Step] {
        var steps = [Step]()
        for entity in entities {
            let inputs = entity
            guard let typePair = StepType.getTypePair(inputs.first),
                  let step = Step.initFromString(typePair: typePair, inputs: Array(inputs.dropFirst()))
            else {
                continue
            }

            steps.append(step)
        }

        return steps
    }

    private func getLocationValues(steps: [Step], seeds: [Int]) -> Int {
        var stepValues: [StepType: [Int]] = [.seed: seeds]
        for step in steps {
            guard let destinationValues = step.getDestinationValues(fromSourceValues: stepValues[step.source]) else {
                continue
            }

            stepValues[step.destination] = destinationValues
        }

        return stepValues[.location]?.min() ?? Int.max
    }
}
