import Algorithms

struct Day01: AdventDay {
    var data: String

    var entities: [[Int]] {
        let entArr = data.split(separator: "\n").map {
            $0.split(separator: "   ").compactMap { Int($0) }
        }

        let firstArr = entArr.map { $0[0] }
        let secondArr = entArr.map { $0[1] }

        return [firstArr, secondArr]
    }

    func part1() -> Any {
        let sortedFirst = entities[0].sorted()
        let sortedSecond = entities[1].sorted()

        var diffCount = 0
        for index in 0 ..< min(sortedFirst.count, sortedSecond.count) {
            diffCount += abs(sortedFirst[index] - sortedSecond[index])
        }
        return diffCount
    }

    func part2() -> Any {
        var similarirtyDict: [Int: Int] = [:]
        for index in 0 ..< entities[1].count {
            if let existingSimilarity = similarirtyDict[entities[1][index]] {
                similarirtyDict[entities[1][index]] = existingSimilarity + 1
            } else {
                similarirtyDict[entities[1][index]] = 1
            }
        }

        return entities[0].map { (similarirtyDict[$0] ?? 0) * $0 }.reduce(0, +)
    }
}
