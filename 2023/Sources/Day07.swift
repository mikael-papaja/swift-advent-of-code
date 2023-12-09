import Algorithms
import Foundation

struct Day07: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    enum Card: Character, Comparable {
        case ace = "A"
        case king = "K"
        case queen = "Q"
        case jack = "J"
        case ten = "T"
        case nine = "9"
        case eight = "8"
        case seven = "7"
        case six = "6"
        case five = "5"
        case four = "4"
        case three = "3"
        case two = "2"
        case joker = "1"

        func getScore() -> Int {
            return switch self {
            case .ace:
                14
            case .king:
                13
            case .queen:
                12
            case .jack:
                11
            case .ten:
                10
            default:
                Int("\(self.rawValue)")!
            }
        }

        static func < (lhs: Day07.Card, rhs: Day07.Card) -> Bool {
            return lhs.getScore() < rhs.getScore()
        }
    }

    enum HandType: Int, CaseIterable {
        case fiveOfAKind = 7
        case fourOfAKind = 6
        case house = 5
        case threeOfAKind = 4
        case twoPair = 3
        case onePair = 2
        case highCard = 1
    }

    struct Hand: Comparable {
        let cards: [Card]
        let bet: Int

        func getType() -> HandType {
            var countCards = cards
            if cards.contains(.joker) {
                countCards = fixJokerCards()
            }

            var counts = [Card: Int]()
            for card in countCards {
                counts[card] = (counts[card] ?? 0) + 1
            }

            return if counts.keys.count == 1 {
                .fiveOfAKind
            } else if counts.values.max() == 4 {
                .fourOfAKind
            } else if counts.keys.count == 2 {
                .house
            } else if counts.values.max() == 3 {
                .threeOfAKind
            } else if counts.values.max() == 2 && counts.values.filter({ $0 == 2 }).count == 2 {
                .twoPair
            } else if counts.values.max() == 2 {
                .onePair
            } else {
                .highCard
            }
        }

        private func fixJokerCards() -> [Card] {
            var counts = [Card: Int]()
            for card in cards {
                counts[card] = (counts[card] ?? 0) + 1
            }

            var maxCard: Card?
            for count in counts where count.key != .joker {
                if maxCard == nil || count.value > counts[maxCard!]! {
                    maxCard = count.key
                }
            }
            guard let maxCard = maxCard else {
                return cards
            }

            return cards.map { $0 == .joker ? maxCard : $0 }
        }

        static func < (lhs: Day07.Hand, rhs: Day07.Hand) -> Bool {
            let lhsType = lhs.getType()
            let rhsType = rhs.getType()
            if lhsType.rawValue != rhsType.rawValue {
                return lhsType.rawValue < rhsType.rawValue
            }

            for index in 0 ..< lhs.cards.count {
                if lhs.cards[index] != rhs.cards[index] {
                    return lhs.cards[index] < rhs.cards[index]
                }
            }

            return false
        }

        static func initFromString(_ input: String) -> Hand? {
            if input.count < 7 {
                return nil
            }
            var cards = [Card]()
            var bet = ""
            for (index, character) in input.replacingOccurrences(of: " ", with: "").enumerated() {
                if index < 5 {
                    guard let card = Card(rawValue: character) else {
                        return nil
                    }
                    cards.append(card)
                    continue
                }

                bet.append(character)
            }

            guard let betValue = Int(bet), cards.count == 5 else {
                return nil
            }

            return Hand(cards: cards, bet: betValue)
        }
    }

    func part1() -> Any {
        return getTotalWinnings(entities.compactMap { Hand.initFromString($0) })
    }

    func part2() -> Any {
        return getTotalWinnings(entities.compactMap { Hand.initFromString($0.replacingOccurrences(of: "J", with: "1")) })
    }

    private func getTotalWinnings(_ hands: [Hand]) -> Int {
        if hands.count != entities.count {
            return 0
        }

        let sortedHands = hands.sorted()
        var returnValue = 0
        for (index, hand) in sortedHands.enumerated() {
            returnValue += (index + 1) * hand.bet
        }

        return returnValue
    }
}
