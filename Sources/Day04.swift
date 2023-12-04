//
//  Day04.swift
//
//
//  Created by Mikael Bergman on 2023-12-01.
//

import Algorithms
import Foundation

struct Day04: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    struct Card {
        var id: Int
        var winningNumbers: [Int]
        var numbers: [Int]

        func getScore() -> Int {
            var score = 0
            for number in numbers {
                if !winningNumbers.contains(number) {
                    continue
                }

                if score == 0 {
                    score = 1
                    continue
                }

                score *= 2
            }

            return score
        }

        func getWinCount() -> Int {
            var winCount = 0
            for number in numbers {
                if !winningNumbers.contains(number) {
                    continue
                }

                winCount += 1
            }

            return winCount
        }

        static func initFromString(_ cardString: String) -> Card? {
            var idString = ""

            for i in 0 ..< cardString.count {
                let prefix = cardString.prefix(i)
                if prefix.last == ":" {
                    idString = String(prefix)
                    break
                }
            }

            guard let cardId = Int(idString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) else {
                return nil
            }

            let card = cardString.replacingOccurrences(of: idString, with: "")
            let numberSets = card.split(separator: "|").compactMap { "\($0)" }

            if numberSets.count != 2 {
                return nil
            }

            let winningNumbers = numberSets[0].trimmingCharacters(in: .whitespaces).split(separator: " ").compactMap { Int("\($0)") }
            let numbers = numberSets[1].trimmingCharacters(in: .whitespaces).split(separator: " ").compactMap { Int("\($0)") }

            if winningNumbers.isEmpty || numbers.isEmpty {
                return nil
            }

            return Card(id: cardId, winningNumbers: winningNumbers, numbers: numbers)
        }
    }

    func part1() -> Any {
        return getCards().map { $0.getScore() }.reduce(0, +)
    }

    func part2() -> Any {
        return getTotalCopies().map { $0.value }.reduce(0, +)
    }

    private func getCards() -> [Card] {
        var cards = [Card]()
        for entity in entities {
            guard let card = Card.initFromString(entity) else {
                continue
            }
            cards.append(card)
        }

        return cards
    }

    private func getTotalCopies() -> [Int: Int] {
        let cards = getCards()
        let cardIds = cards.map { $0.id }.sorted()
        var copies: [Int: Int] = cardIds.reduce(into: [Int: Int]()) { $0[$1] = 1 }
        for cardId in cardIds {
            guard let card = cards.first(where: { $0.id == cardId }) else {
                continue
            }

            let winCount = card.getWinCount()
            if winCount > 0 {
                for i in 1 ... winCount {
                    copies[cardId + i] = (copies[cardId + i] ?? 1) + (copies[cardId] ?? 1)
                }
            }
        }

        return copies
    }
}
