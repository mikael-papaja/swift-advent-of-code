import Algorithms
import Foundation

struct Day10: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    enum Tile: Character {
        case verticalPipe = "|"
        case horizontalPipe = "-"
        case northEastBend = "L"
        case northWestBend = "J"
        case southWestBend = "7"
        case southEastBend = "F"
        case ground = "."
        case startingPosition = "S"

        func getNextDirection(comingFrom direction: Direction) -> Direction? {
            return switch direction {
            case .north:
                switch self {
                case .verticalPipe: .south
                case .northEastBend: .east
                case .northWestBend: .west
                default: nil
                }
            case .east:
                switch self {
                case .horizontalPipe: .west
                case .northEastBend: .north
                case .southEastBend: .south
                default: nil
                }
            case .south:
                switch self {
                case .verticalPipe: .north
                case .southWestBend: .west
                case .southEastBend: .east
                default: nil
                }
            case .west:
                switch self {
                case .horizontalPipe: .east
                case .northWestBend: .north
                case .southWestBend: .south
                default: nil
                }
            }
        }

        func getDetailedSquaure() -> [[TileState]] {
            return switch self {
            case .verticalPipe: [
                    [.open, .blocked, .open],
                    [.open, .blocked, .open],
                    [.open, .blocked, .open]
                ]
            case .horizontalPipe: [
                    [.open, .open, .open],
                    [.blocked, .blocked, .blocked],
                    [.open, .open, .open]
                ]
            case .northEastBend: [
                    [.open, .blocked, .open],
                    [.open, .blocked, .blocked],
                    [.open, .open, .open]
                ]
            case .northWestBend: [
                    [.open, .blocked, .open],
                    [.blocked, .blocked, .open],
                    [.open, .open, .open]
                ]
            case .southWestBend: [
                    [.open, .open, .open],
                    [.blocked, .blocked, .open],
                    [.open, .blocked, .open]
                ]
            case .southEastBend: [
                    [.open, .open, .open],
                    [.open, .blocked, .blocked],
                    [.open, .blocked, .open]
                ]
            case .ground: [
                    [.open, .open, .open],
                    [.open, .open, .open],
                    [.open, .open, .open]
                ]
            case .startingPosition: [
                    [.blocked, .blocked, .blocked],
                    [.blocked, .blocked, .blocked],
                    [.blocked, .blocked, .blocked]
                ]
            }
        }
    }

    enum TileState: String {
        case enclosed = "E"
        case blocked = "X"
        case open = "O"

        var printValue: String {
            switch self {
            case .enclosed: "🟦"
            case .blocked: "🟥"
            case .open: "🟩"
            }
        }
    }

    enum Direction: Int, CaseIterable {
        case north
        case east
        case south
        case west

        func getOpposite() -> Direction {
            switch self {
            case .north: return .south
            case .east: return .west
            case .south: return .north
            case .west: return .east
            }
        }
    }

    struct Coordinate: Hashable {
        let x: Int
        let y: Int

        func getNextCoordinate(from direction: Direction) -> Coordinate {
            switch direction {
            case .north: return Coordinate(x: x, y: y - 1)
            case .east: return Coordinate(x: x + 1, y: y)
            case .south: return Coordinate(x: x, y: y + 1)
            case .west: return Coordinate(x: x - 1, y: y)
            }
        }

        static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
    }

    struct DetailedTile {
        let coordinate: Coordinate
        let detailedCoordinate: Coordinate
        var tileState: TileState

        var description: String {
            return tileState.printValue
        }

        mutating func block() {
            tileState = .blocked
        }
    }

    struct CoordinateRange {
        let start: Coordinate
        let stop: Coordinate

        func toDetailedCoordinates() -> [Coordinate] {
            let xRange = ((start.x + 1) * 3) ... ((stop.x * 3) - 1)
            let yRange = (start.y * 3) ..< ((start.y * 3) + 3)
            var returnArray = [Coordinate]()

            for x in xRange {
                for y in yRange {
                    returnArray.append(Coordinate(x: x, y: y))
                }
            }

            return returnArray
        }

        func getCount() -> Int {
            return stop.x - start.x - 1
        }
    }

    struct Map {
        let tiles: [[Tile]]
        let startingPoint: Coordinate
    }

    func part1() -> Any {
        return getFullLoop(generateMap()).count / 2
    }

    func part2() -> Any {
        return getAllEnclosedTiles(generateMap())
    }

    private func generateMap() -> Map {
        var startingPoint = Coordinate(x: 0, y: 0)
        var tiles = [[Tile]]()
        for entity in entities {
            let rowTiles = entity.map { Tile(rawValue: $0)! }
            if let index = rowTiles.firstIndex(of: .startingPosition) {
                startingPoint = Coordinate(x: index, y: tiles.count)
            }
            tiles.append(rowTiles)
        }

        return Map(tiles: tiles, startingPoint: startingPoint)
    }

    private func getFullLoop(_ map: Map) -> [Coordinate] {
        var biggestLoop = [Coordinate]()
        for direction in Direction.allCases {
            guard let path = getLoopCount(from: map.startingPoint, direction: direction, inMap: map.tiles) else {
                continue
            }

            biggestLoop = biggestLoop.count > path.count ? biggestLoop : path
        }

        return biggestLoop
    }

    private func getLoopCount(from coordinate: Coordinate, direction: Direction, inMap map: [[Tile]]) -> [Coordinate]? {
        var currentCoordinate = coordinate
        var currentDirection = direction
        var path = [Coordinate]()

        while true {
            let nextCoordinate = currentCoordinate.getNextCoordinate(from: currentDirection)
            if isCoordinateOutOfBounds(nextCoordinate, inMap: map) {
                return nil
            }

            path.append(currentCoordinate)
            let nextTile = map[nextCoordinate.y][nextCoordinate.x]
            if nextTile == .ground {
                return nil
            } else if nextTile == .startingPosition {
                return path
            }

            guard let nextDirection = nextTile.getNextDirection(comingFrom: currentDirection.getOpposite()) else {
                return nil
            }

            currentCoordinate = nextCoordinate
            currentDirection = nextDirection
        }
    }

    private func getAllEnclosedTiles(_ map: Map) -> Int {
        let fullLoop = getFullLoop(map)
        let startingTile = getStartingTile(previous: fullLoop.last!, middle: fullLoop[0], next: fullLoop[1])
        var detailedTiles = [[DetailedTile]]()
        var coordinateRanges = [CoordinateRange]()
        for (y, tileRow) in map.tiles.enumerated() {
            var rows: [[DetailedTile]] = [[], [], []]
            var currentRangeStart: Coordinate?
            for (x, tile) in tileRow.enumerated() {
                let coordinate = Coordinate(x: x, y: y)
                let loopIndex = fullLoop.firstIndex(where: { $0 == coordinate })
                let detailedSquare = loopIndex == 0 ? startingTile.getDetailedSquaure() : tile.getDetailedSquaure()
                if currentRangeStart != nil && loopIndex != nil {
                    for (innerY, detailedRow) in detailedSquare.enumerated() {
                        for (innerX, detailedTile) in detailedRow.enumerated() {
                            rows[innerY].append(DetailedTile(
                                coordinate: coordinate,
                                detailedCoordinate: Coordinate(x: innerX, y: innerY),
                                tileState: detailedTile
                            ))
                        }
                    }
                    if x - currentRangeStart!.x > 1 {
                        coordinateRanges.append(CoordinateRange(start: currentRangeStart!, stop: coordinate))
                    }
                    currentRangeStart = coordinate
                } else if loopIndex != nil {
                    for (innerY, detailedRow) in detailedSquare.enumerated() {
                        for (innerX, detailedTile) in detailedRow.enumerated() {
                            rows[innerY].append(DetailedTile(
                                coordinate: coordinate,
                                detailedCoordinate: Coordinate(x: innerX, y: innerY),
                                tileState: detailedTile
                            ))
                        }
                    }
                    if currentRangeStart == nil {
                        currentRangeStart = coordinate
                    }
                } else {
                    for innerY in 0 ..< 3 {
                        for innerX in 0 ..< 3 {
                            rows[innerY].append(DetailedTile(
                                coordinate: coordinate,
                                detailedCoordinate: Coordinate(x: innerX, y: innerY),
                                tileState: .open
                            ))
                        }
                    }
                }
            }
            currentRangeStart = nil
            for row in rows {
                detailedTiles.append(row)
            }
        }

        for range in coordinateRanges {
            let detailedCoordinates = range.toDetailedCoordinates()

            for detailedCoordinate in detailedCoordinates {
                detailedTiles[detailedCoordinate.y][detailedCoordinate.x].tileState = .enclosed
            }
        }

        var tiles = detailedTiles
        var tilesToCheck = [Coordinate]()
        for x in 0 ..< tiles[0].count {
            tilesToCheck.append(Coordinate(x: x, y: 0))
            tilesToCheck.append(Coordinate(x: x, y: tiles.count - 1))
        }
        for y in 0 ..< tiles.count {
            tilesToCheck.append(Coordinate(x: 0, y: y))
            tilesToCheck.append(Coordinate(x: tiles[y].count - 1, y: y))
        }

        let xMax = tiles[0].count
        let yMax = tiles.count
        while !tilesToCheck.isEmpty {
            let coordinate = tilesToCheck.removeFirst()
            let x = coordinate.x
            let y = coordinate.y

            if x < 0 || y < 0 || x >= xMax || y >= yMax {
                continue
            }

            if tiles[y][x].tileState == .blocked {
                continue
            }
            tiles[y][x].block()

            tilesToCheck.append(Coordinate(x: x + 1, y: y))
            tilesToCheck.append(Coordinate(x: x - 1, y: y))
            tilesToCheck.append(Coordinate(x: x, y: y + 1))
            tilesToCheck.append(Coordinate(x: x, y: y - 1))
        }

        var simpleArray = [[TileState]]()
        for (y, tileRow) in tiles.enumerated() {
            guard y % 3 == 1 else { continue }
            var simpleRow = [TileState]()

            for (x, tile) in tileRow.enumerated() {
                guard x % 3 == 1 else { continue }
                simpleRow.append(tile.tileState)
            }
            simpleArray.append(simpleRow)
        }

        print(detailedTiles.map { $0.map { $0.description }.joined() }.joined(separator: "\n"))
        print("\n")
        print(tiles.map { $0.map { $0.description }.joined() }.joined(separator: "\n"))
        print("\n")
        print(simpleArray.map { $0.map { $0.printValue }.joined() }.joined(separator: "\n"))
        print("\n")

        return simpleArray.map { $0.map { $0 == .enclosed ? 1 : 0 }.reduce(0, +) }.reduce(0, +)
    }

    private func isCoordinateOutOfBounds(_ coordinate: Coordinate, inMap map: [[Tile]]) -> Bool {
        return coordinate.x < 0 || coordinate.y < 0 || coordinate.y >= map.count || coordinate.x >= map[coordinate.y].count
    }

    private func getStartingTile(previous: Coordinate, middle: Coordinate, next: Coordinate) -> Tile {
        return if previous.x == next.x {
            .verticalPipe
        } else if previous.y == next.y {
            .horizontalPipe
        } else if previous.x < next.x && previous.y < next.y {
            middle.x == previous.x ? .northEastBend : .southWestBend
        } else if previous.x > next.x && previous.y < next.y {
            middle.x == previous.x ? .northWestBend : .southEastBend
        } else if previous.x < next.x && previous.y > next.y {
            middle.x == previous.x ? .southEastBend : .northWestBend
        } else if previous.x > next.x && previous.y > next.y {
            middle.x == previous.x ? .southWestBend : .northEastBend
        } else {
            .ground
        }
    }
}
