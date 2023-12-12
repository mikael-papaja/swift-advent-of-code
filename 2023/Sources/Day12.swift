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
            let dateState = Date()
            print("Started with: \(conditions)")
            var arrangements = [Arrangement]()
            for (conditionIndex, conditionCount) in conditions.enumerated() {
                let loopDate = Date()
                let totalRemainingConditions = conditions[min(conditionIndex + 1, conditions.count - 1) ..< conditions.count].reduce(0, +)
                let maxRemaining = max(0, totalRemainingConditions + (conditions.count - conditionIndex - 1))
                if conditionIndex == 0 {
                    for typeIndex in 0 ..< types.count {
                        if typeIndex + conditionCount > types.count {
                            break
                        }

                        let currentRemaining = types.count - typeIndex
                        let remainingNonOperational = types[(typeIndex + conditionCount - 1) ..< types.count].filter { $0 != .operational }.count
                        if maxRemaining > currentRemaining || totalRemainingConditions > remainingNonOperational {
                            break
                        }

                        if let arrangement = getArrangement(types, typeIndex: typeIndex, conditionCount: conditionCount) {
                            arrangements.append(arrangement)
                        }
                    }
                } else {
                    var newArrangements = [Arrangement]()
                    for arrangement in arrangements {
                        for typeIndex in 0 ..< arrangement.types.count {
                            if typeIndex < arrangement.startingIndex {
                                continue
                            }

                            if typeIndex + conditionCount > arrangement.types.count {
                                break
                            }

                            let currentRemaining = types.count - typeIndex
                            let remainingNonOperational = types[typeIndex ..< types.count].filter { $0 != .operational }.count
                            if maxRemaining > currentRemaining || totalRemainingConditions > remainingNonOperational {
                                break
                            }

                            if let newArrangement = getArrangement(
                                arrangement.types,
                                typeIndex: typeIndex,
                                conditionCount: conditionCount,
                                isLast: conditionIndex == conditions.count - 1
                            ) {
                                newArrangements.append(newArrangement)
                            }
                        }
                    }

                    arrangements = newArrangements
                }
                print("Condition \(conditionIndex + 1) of \(conditions.count) - \(Date().timeIntervalSince(loopDate))")
            }

            print("Loop done: \(arrangements.count) - \(Date().timeIntervalSince(dateState))")

            let typeArrays = Array(Set(arrangements.map { $0.types }))

            print("Filter done: \(typeArrays.count) - \(Date().timeIntervalSince(dateState))")

            var matchingArrengementCount = 0
            for typeArray in typeArrays {
                let currentConditions = typeArray.split(separator: .operational).map { $0.count }
                if currentConditions == conditions {
                    matchingArrengementCount += 1
                }
//                var currentConditions = [Int]()
//                var currentCondition = 0
//                for type in typeArray {
//                    if type == .damaged {
//                        currentCondition += 1
//                    } else if currentCondition > 0 {
//                        currentConditions.append(currentCondition)
//                        currentCondition = 0
//                    }
//                }
//                if currentCondition > 0 {
//                    currentConditions.append(currentCondition)
//                }
//                if currentConditions == conditions {
//                    matchingArrengementCount += 1
//                }
            }

            print("Matching count: \(matchingArrengementCount) - \(Date().timeIntervalSince(dateState))\n")
            return matchingArrengementCount
        }

        private func getArrangement(_ types: [RecordType], typeIndex: Int, conditionCount: Int, isLast: Bool = false) -> Arrangement? {
            let subRange = typeIndex ..< typeIndex + conditionCount
            if subRange.allSatisfy({ types[$0] == .damaged || types[$0] == .unknown }) {
                var arrangement = types
                arrangement.replaceSubrange(subRange, with: Array(repeating: .damaged, count: conditionCount))
                if typeIndex + conditionCount < types.count {
                    if types[typeIndex + conditionCount] == .damaged {
                        return nil
                    } else if types[typeIndex + conditionCount] == .unknown {
                        arrangement[typeIndex + conditionCount] = .operational
                    }
                }
                if typeIndex > 0 {
                    if types[typeIndex - 1] == .damaged {
                        return nil
                    } else if types[typeIndex - 1] == .unknown {
                        arrangement[typeIndex - 1] = .operational
                    }
                }

                if isLast {
                    arrangement = arrangement.map {  $0 == .unknown ? .operational : $0}
                }

                return Arrangement(types: arrangement, startingIndex: typeIndex + conditionCount + 1)
            }

            return nil
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
