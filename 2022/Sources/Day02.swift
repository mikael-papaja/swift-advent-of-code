//
import Algorithms
import Foundation

struct Day02: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[String]] {
        data.split(separator: "\n").map {
            $0.split(separator: " ").compactMap { "\($0)" }
        }
    }

    enum Hand: Int, CaseIterable {
        case rock = 1
        case paper = 2
        case scissors = 3

        func beats(_ other: Hand) -> Bool? {
            if self == other { return nil }

            return switch self {
            case .rock: other == .scissors
            case .paper: other == .rock
            case .scissors: other == .paper
            }
        }

        func getWinning() -> Hand {
            return switch self {
            case .rock: .paper
            case .paper: .scissors
            case .scissors: .rock
            }
        }

        func getLosing() -> Hand {
            return switch self {
            case .rock: .scissors
            case .paper: .rock
            case .scissors: .paper
            }
        }

        static func fromValue(_ value: String?) -> Hand? {
            return switch value {
            case "A", "X": .rock
            case "B", "Y": .paper
            case "C", "Z": .scissors
            default: nil
            }
        }
    }

    enum Strategy: String {
        case win = "Z"
        case lose = "X"
        case draw = "Y"
    }

    struct Game {
        let opponentHand: Hand
        let strategy: Strategy

        func getUserHand() -> Hand {
            return switch strategy {
            case .win: opponentHand.getWinning()
            case .lose: opponentHand.getLosing()
            case .draw: opponentHand
            }
        }

        static func fromValues(_ values: [String]) -> Game? {
            guard values.count == 2 else { return nil }
            guard let opponentHand = Hand.fromValue(values[0]) else { return nil }
            guard let strategy = Strategy(rawValue: values[1]) else { return nil }
            return Game(opponentHand: opponentHand, strategy: strategy)
        }
    }

    func part1() -> Any {
        return entities.map { $0.compactMap(Hand.fromValue) }.map { getHandScore($0[0], $0[1]) }.reduce(0, +)
    }

    func part2() -> Any {
        return entities.compactMap { Game.fromValues($0) }.map { getHandScore($0.opponentHand, $0.getUserHand()) }.reduce(0, +)
    }

    private func getHandScore(_ opponentHand: Hand, _ myHand: Hand) -> Int {
        let result = switch myHand.beats(opponentHand) {
        case true: 6
        case false: 0
        default: 3
        }

        return result + myHand.rawValue
    }
}
