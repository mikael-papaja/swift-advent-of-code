import Algorithms

struct Day03: AdventDay {
    var data: String

    var entities: String {
        data
    }

    func part1() -> Any {
        let firstRegex = try! Regex(#"(mul\(\d{1,3},\d{1,3}\))"#)
        let secondRegex = try! Regex(#"(\d{1,3},\d{1,3})"#)
        let firstMatches = entities.matches(of: firstRegex)

        let multiples: [(Int, Int)] = firstMatches.flatMap { firstMatch in
            "\(firstMatch.0)".matches(of: secondRegex).compactMap { secondMatch in
                let split = "\(secondMatch.0)".split(separator: ",")
                guard split.count == 2, let first = Int(split[0]), let second = Int(split[1]) else {
                    return nil
                }

                return (first, second)
            }
        }

        return multiples.reduce(0) { $0 + ($1.0 * $1.1) }
    }

    func part2() -> Any {
        let firstRegex = try! Regex(#"(mul\(\d{1,3},\d{1,3}\))|(don't\(\))|(do\(\))"#)
        let secondRegex = try! Regex(#"(\d{1,3},\d{1,3})"#)
        let firstMatches = entities.matches(of: firstRegex)
        var multiples = [(Int, Int)]()
        
        var includeMatch: Bool = true
        for firstMatch in firstMatches {
            let matchedValue = "\(firstMatch.0)"
            if matchedValue == "don't()" {
                includeMatch = false
                continue
            }
            if matchedValue == "do()" {
                includeMatch = true
            }
            
            if !includeMatch {
                continue
            }
            
            multiples += matchedValue.matches(of: secondRegex).compactMap { secondMatch in
                let split = "\(secondMatch.0)".split(separator: ",")
                guard split.count == 2, let first = Int(split[0]), let second = Int(split[1]) else {
                    return nil
                }

                return (first, second)
            }
        }

        return multiples.reduce(0) { $0 + ($1.0 * $1.1) }
    }
}
