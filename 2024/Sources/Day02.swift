import Algorithms

struct Day02: AdventDay {
    var data: String

    var entities: [[Int]] {
        data.split(separator: "\n").map {
            $0.split(separator: " ").compactMap { Int($0) }
        }
    }

    func part1() -> Any {
        return getSafeCount(entities)
    }

    func part2() -> Any {
        return getSafeCount(entities, includeDampening: true)
    }

    private func getSafeCount(_ data: [[Int]], includeDampening: Bool = false) -> Int {
        var safeCount = 0

        for i in 0 ..< data.count {
            var isIncreasing = false
            var isSafe = false

            for j in 0 ..< data[i].count {
                if j + 1 == data[i].count {
                    break
                }

                let difference = data[i][j + 1] - data[i][j]
                if difference == 0 || abs(difference) > 3 {
                    isSafe = false
                    if includeDampening && worksWithDampening(data[i]) {
                        isSafe = true
                    }
                    break
                }

                if j == 0 {
                    isIncreasing = difference > 0
                }

                if !isIncreasing && difference > 0 {
                    isSafe = false
                    if includeDampening && worksWithDampening(data[i]) {
                        isSafe = true
                    }
                    break
                }

                if isIncreasing && difference < 0 {
                    isSafe = false
                    if includeDampening && worksWithDampening(data[i]) {
                        isSafe = true
                    }
                    break
                }

                isSafe = true
            }

            if isSafe {
                safeCount += 1
            }
        }

        return safeCount
    }
    
    private func worksWithDampening(_ data: [Int]) -> Bool {
        for i in 0 ..< data.count {
            var fixedArray = data
            fixedArray.remove(at: i)
            if getSafeCount([fixedArray]) > 0 {
                return true
            }
        }
        
        return false
    }
}
