import Algorithms
import Foundation

struct Day15: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[Character]] {
        data.components(separatedBy: ",").compactMap {
            let characters = Array($0.trimmingCharacters(in: .whitespacesAndNewlines))
            return characters.isEmpty ? nil : characters
        }
    }

    enum Operation: Character {
        case remove = "-"
        case addOrReplace = "="
    }

    struct Instruction {
        let hash: Int
        let label: String
        let operation: Operation!
        let focalLength: Int?

        static func initFromCharacters(_ input: [Character], getHashValue: ([Character]) -> Int) -> Instruction? {
            var label = ""
            var operation: Operation?
            var focalLength = ""
            for character in input {
                if character.isLetter {
                    label.append(character)
                } else if character.isNumber {
                    focalLength.append(character)
                } else if let op = Operation(rawValue: character) {
                    operation = op
                }
            }

            guard let op = operation, !label.isEmpty else { return nil }

            return Instruction(hash: getHashValue(Array(label)), label: label, operation: op, focalLength: Int(focalLength))
        }
    }

    struct Box {
        var lenses: [Lens] = []
    }

    struct Lens {
        var label: String
        var focalLength: Int
    }

    func part1() -> Any {
        return entities.map { getHashValue($0) }.reduce(0, +)
    }

    func part2() -> Any {
        return getFocusingPower()
    }

    func getHashValue(_ input: [Character]) -> Int {
        var currentValue = 0
        for character in input {
            guard let ascii = character.asciiValue else { continue }
            currentValue += Int(ascii)
            currentValue *= 17
            currentValue = currentValue % 256
        }
        return currentValue
    }

    func getFocusingPower() -> Int {
        let instructions = entities.compactMap { Instruction.initFromCharacters($0, getHashValue: getHashValue(_:)) }

        var boxes = [Box]()
        for _ in 0 ..< 256 {
            boxes.append(Box())
        }

        for instruction in instructions {
            switch instruction.operation {
            case .addOrReplace:
                guard let foxalLength = instruction.focalLength else { continue }
                let lens = Lens(label: instruction.label, focalLength: foxalLength)
                if let index = boxes[instruction.hash].lenses.firstIndex(where: { $0.label == instruction.label }) {
                    boxes[instruction.hash].lenses[index] = lens
                } else {
                    boxes[instruction.hash].lenses.append(lens)
                }
            case .remove:
                if let index = boxes[instruction.hash].lenses.firstIndex(where: { $0.label == instruction.label }) {
                    boxes[instruction.hash].lenses.remove(at: index)
                }
            default:
                continue
            }
        }

        var focusingPower = 0
        for (boxIndex, box) in boxes.enumerated() {
            for (slotIndex, lens) in box.lenses.enumerated() {
                focusingPower += ((boxIndex + 1) * (slotIndex + 1) * lens.focalLength)
            }
        }

        return focusingPower
    }
}
