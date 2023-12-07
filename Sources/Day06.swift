import Algorithms
import Foundation

struct Day06: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    struct Race {
        let times: [Int]
        let distances: [Int]

        func getNewRecords() -> [Int] {
            var newRecords = [Int]()
            for (index, time) in times.enumerated() {
                newRecords.append(getRecordCount(forTime: time, record: distances[index]))
            }

            return newRecords
        }

        func getRecordsForCombined() -> Int {
            var time = ""
            var distance = ""
            for index in 0..<times.count {
                time += "\(times[index])"
                distance += "\(distances[index])"
            }

            guard let timeValue = Int(time), let distanceValue = Int(distance) else {
                return 0
            }

            return getRecordCount(forTime: timeValue, record: distanceValue)
        }

        private func getRecordCount(forTime time: Int, record: Int) -> Int {
            var records = 0
            for index in 0 ... time {
                if index * (time - index) > record {
                    records += 1
                }
            }

            return records
        }

        static func initFromStrings(_ inputs: [String]) -> Race? {
            var times = [Int]()
            var distances = [Int]()

            for input in inputs {
                if input.contains("Time:") {
                    times = getIntValues(input.replacingOccurrences(of: "Time:", with: "").trimmingCharacters(in: .whitespaces))
                } else if input.contains("Distance:") {
                    distances = getIntValues(input.replacingOccurrences(of: "Distance:", with: "").trimmingCharacters(in: .whitespaces))
                }
            }

            if times.isEmpty || distances.isEmpty || times.count != distances.count {
                return nil
            }

            return Race(times: times, distances: distances)
        }

        private static func getIntValues(_ input: String) -> [Int] {
            var returnValues = [Int]()
            var currentValue = ""

            for character in input {
                if character.isWholeNumber {
                    currentValue.append(character)
                } else {
                    if let value = Int(currentValue) {
                        returnValues.append(value)
                    }
                    currentValue = ""
                }
            }

            if let value = Int(currentValue) {
                returnValues.append(value)
            }

            return returnValues
        }
    }

    func part1() -> Any {
        return Race.initFromStrings(entities)?.getNewRecords().reduce(1, *) ?? 0
    }

    func part2() -> Any {
        return Race.initFromStrings(entities)?.getRecordsForCombined() ?? 0
    }
}
