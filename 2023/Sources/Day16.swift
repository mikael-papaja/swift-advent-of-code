import Algorithms
import Foundation

struct Day16: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [[Character]] {
        data.components(separatedBy: "\n").compactMap { Array($0) }
    }

    enum Direction: Hashable {
        case up
        case down
        case left
        case right

        var opposite: Direction {
            switch self {
            case .up:
                return .down
            case .down:
                return .up
            case .left:
                return .right
            case .right:
                return .left
            }
        }

        var isVertical: Bool {
            return self == .up || self == .down
        }

        func getNextCoordinate(coordinate: Coordinate) -> Coordinate {
            switch self {
            case .up:
                return Coordinate(x: coordinate.x, y: coordinate.y - 1)
            case .down:
                return Coordinate(x: coordinate.x, y: coordinate.y + 1)
            case .left:
                return Coordinate(x: coordinate.x - 1, y: coordinate.y)
            case .right:
                return Coordinate(x: coordinate.x + 1, y: coordinate.y)
            }
        }
    }

    enum TileType: Character {
        case empty = "."
        case verticalSplit = "|"
        case horizontalSplit = "-"
        case leftRightAngle = "/"
        case rightLeftAngle = "\\"

        var printValue: String {
            switch self {
            case .empty:
                return "⏺️"
            case .verticalSplit:
                return "↕️"
            case .horizontalSplit:
                return "↔️"
            case .leftRightAngle:
                return "↗️"
            case .rightLeftAngle:
                return "↖️"
            }
        }

        func getNextCoordinates(coordinate: Coordinate, comingFrom: Direction) -> [Movement] {
            return switch self {
            case .empty:
                [Movement(coordinate: comingFrom.opposite.getNextCoordinate(coordinate: coordinate), comingFrom: comingFrom)]
            case .verticalSplit:
                switch comingFrom {
                case .down, .up:
                    [Movement(coordinate: comingFrom.opposite.getNextCoordinate(coordinate: coordinate), comingFrom: comingFrom)]
                case .left, .right:
                    [
                        Movement(coordinate: Direction.down.getNextCoordinate(coordinate: coordinate), comingFrom: .up),
                        Movement(coordinate: Direction.up.getNextCoordinate(coordinate: coordinate), comingFrom: .down)
                    ]
                }
            case .horizontalSplit:
                switch comingFrom {
                case .left, .right:
                    [Movement(coordinate: comingFrom.opposite.getNextCoordinate(coordinate: coordinate), comingFrom: comingFrom)]
                case .down, .up:
                    [
                        Movement(coordinate: Direction.left.getNextCoordinate(coordinate: coordinate), comingFrom: .right),
                        Movement(coordinate: Direction.right.getNextCoordinate(coordinate: coordinate), comingFrom: .left)
                    ]
                }
            case .leftRightAngle:
                switch comingFrom {
                case .up:
                    [Movement(coordinate: Direction.left.getNextCoordinate(coordinate: coordinate), comingFrom: .right)]
                case .down:
                    [Movement(coordinate: Direction.right.getNextCoordinate(coordinate: coordinate), comingFrom: .left)]
                case .left:
                    [Movement(coordinate: Direction.up.getNextCoordinate(coordinate: coordinate), comingFrom: .down)]
                case .right:
                    [Movement(coordinate: Direction.down.getNextCoordinate(coordinate: coordinate), comingFrom: .up)]
                }
            case .rightLeftAngle:
                switch comingFrom {
                case .up:
                    [Movement(coordinate: Direction.right.getNextCoordinate(coordinate: coordinate), comingFrom: .left)]
                case .down:
                    [Movement(coordinate: Direction.left.getNextCoordinate(coordinate: coordinate), comingFrom: .right)]
                case .left:
                    [Movement(coordinate: Direction.down.getNextCoordinate(coordinate: coordinate), comingFrom: .up)]
                case .right:
                    [Movement(coordinate: Direction.up.getNextCoordinate(coordinate: coordinate), comingFrom: .down)]
                }
            }
        }
    }

    struct Coordinate: Hashable {
        let x: Int
        let y: Int
    }

    struct Map {
        let tiles: [Coordinate: TileType]
    }

    struct Movement: Hashable {
        let coordinate: Coordinate
        let comingFrom: Direction
    }

    func part1() -> Any {
        return getLitTileCount(getMap(), startingMovement: Movement(coordinate: Coordinate(x: 0, y: 0), comingFrom: .left))
    }

    func part2() -> Any {
        return getLargestTileCount(getMap())
    }

    func getMap() -> Map {
        var tiles = [Coordinate: TileType]()
        for (y, row) in entities.enumerated() {
            for (x, tile) in row.enumerated() {
                tiles[Coordinate(x: x, y: y)] = TileType(rawValue: tile)
            }
        }

        return Map(tiles: tiles)
    }

    func getLitTileCount(_ map: Map, startingMovement: Movement) -> Int {
        var queue: [Movement] = [startingMovement]
        var visitedTiles = Set<Movement>()

        while !queue.isEmpty {
            let currentMovement = queue.removeFirst()
            guard let currentTile = map.tiles[currentMovement.coordinate] else { continue }
            if visitedTiles.contains(currentMovement) { continue }
            // printCurrentState(map: map, visitedTiles: visitedTiles, currentMovement: currentMovement)
            visitedTiles.insert(currentMovement)
            let nextMovements = currentTile.getNextCoordinates(coordinate: currentMovement.coordinate, comingFrom: currentMovement.comingFrom)
            queue.append(contentsOf: nextMovements)
        }

        return Array(visitedTiles.map { $0.coordinate }.uniqued()).count
    }

    func getLargestTileCount(_ map: Map) -> Int {
        var startingMovements: [Movement] = []
        for tile in map.tiles.keys {
            if tile.y == 0 {
                startingMovements.append(Movement(coordinate: tile, comingFrom: .up))
            }
            if tile.y == entities.count - 1 {
                startingMovements.append(Movement(coordinate: tile, comingFrom: .down))
            }
            if tile.x == 0 {
                startingMovements.append(Movement(coordinate: tile, comingFrom: .left))
            }
            if tile.x == entities[0].count - 1 {
                startingMovements.append(Movement(coordinate: tile, comingFrom: .right))
            }
        }

        var largestTileCount = 0
        for startingMovement in startingMovements {
            let tileCount = getLitTileCount(map, startingMovement: startingMovement)
            if tileCount > largestTileCount {
                largestTileCount = tileCount
            }
        }

        return largestTileCount
    }

    // Just for fun.
    func printCurrentState(map: Map, visitedTiles: Set<Movement>, currentMovement: Movement) {
        var printMatrix = [[String]]()
        for y in 0 ..< entities.count {
            var row = [String]()
            for x in 0 ..< entities[0].count {
                let coordinate = Coordinate(x: x, y: y)
                if visitedTiles.contains(where: { $0.coordinate == coordinate }) {
                    row.append("🟦")
                } else if coordinate == currentMovement.coordinate {
                    row.append("🟩")
                } else {
                    let printValue = map.tiles[coordinate]?.printValue ?? TileType.empty.printValue
                    row.append(printValue)
                }
            }
            printMatrix.append(row)
        }
        print("\n")
        print(printMatrix.map { $0.joined() }.joined(separator: "\n"))
        usleep(200000)
    }
}
