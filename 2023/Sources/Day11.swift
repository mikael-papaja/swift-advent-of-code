import Algorithms
import Foundation

struct Day11: AdventDay {
    // Save your data in a corresponding text file in the `Data` directory.
    var data: String

    // Splits input data into its component parts and convert from string.
    var entities: [String] {
        data.split(separator: "\n").compactMap { "\($0)" }
    }

    enum Tile: Character {
        case emptySpace = "."
        case galaxy = "#"
    }

    struct Coordinate: Hashable {
        let x: Int
        let y: Int
    }

    struct Galaxy {
        let id: Int
        let coordinates: Coordinate
    }

    struct GalaxyPair {
        let id1: Int
        let id2: Int

        static func == (lhs: GalaxyPair, rhs: GalaxyPair) -> Bool {
            return (lhs.id1 == rhs.id1 && lhs.id2 == rhs.id2) || (lhs.id1 == rhs.id2 && lhs.id2 == rhs.id1)
        }
    }

    struct Universe {
        let tiles: [[Tile]]
        let preExpanseGalaxies: [Galaxy]
        let galaxies: [Galaxy]
        let galaxyPairs: [GalaxyPair]
    }

    func part1() -> Any {
        return findAllPairDistances(parseUniverse()).reduce(0, +)
    }

    func part2() -> Any {
        return findHugeExpanseDistance(parseUniverse()).reduce(0, +)
    }

    private func findAllPairDistances(_ universe: Universe) -> [Int] {
        var distances = [Int]()
        for pair in universe.galaxyPairs {
            let distance = findShortestPath(from: universe.galaxies[pair.id1], to: universe.galaxies[pair.id2])
            distances.append(distance)
        }

        return distances
    }

    private func findShortestPath(from: Galaxy, to: Galaxy) -> Int {
        return abs(from.coordinates.y - to.coordinates.y) + abs(from.coordinates.x - to.coordinates.x)
    }

    private func findHugeExpanseDistance(_ universe: Universe) -> [Int] {
        var distances = [Int]()
        for pair in universe.galaxyPairs {
            let distance = findShortestExpansePath(
                preGalaxy1: universe.preExpanseGalaxies[pair.id1],
                preGalaxy2: universe.preExpanseGalaxies[pair.id2],
                galaxy1: universe.galaxies[pair.id1],
                galaxy2: universe.galaxies[pair.id2]
            )
            distances.append(distance)
        }

        return distances
    }

    private func findShortestExpansePath(preGalaxy1: Galaxy, preGalaxy2: Galaxy, galaxy1: Galaxy, galaxy2: Galaxy) -> Int {
        let preDistance = findShortestPath(from: preGalaxy1, to: preGalaxy2)
        let distance = findShortestPath(from: galaxy1, to: galaxy2)
        let distanceDiff = distance - preDistance
        // return preDistance + (distanceDiff * 99) Test case
        return preDistance + (distanceDiff * 999_999)
    }

    private func parseUniverse() -> Universe {
        var map = entities.map { row in
            row.map { Tile(rawValue: $0)! }
        }

        let preExpanseGalaxies = getGalaxies(map)

        let columns = map[0].count
        for index in (0 ..< columns).reversed() {
            if map.map({ $0[index] }).allSatisfy({ $0 == .emptySpace }) {
                for rowIndex in 0 ..< map.count {
                    map[rowIndex].insert(.emptySpace, at: index)
                }
            }
        }

        let rows = map.count
        for index in (0 ..< rows).reversed() {
            if map[index].allSatisfy({ $0 == .emptySpace }) {
                map.insert(Array(repeating: .emptySpace, count: map[index].count), at: index)
            }
        }

        let galaxies = getGalaxies(map)
        return Universe(tiles: map, preExpanseGalaxies: preExpanseGalaxies, galaxies: galaxies, galaxyPairs: getGalaxyPairs(galaxies))
    }

    private func getGalaxies(_ map: [[Tile]]) -> [Galaxy] {
        var galaxies = [Galaxy]()
        for y in 0 ..< map.count {
            for x in 0 ..< map[y].count {
                if map[y][x] == .galaxy {
                    let galaxy = Galaxy(id: galaxies.count, coordinates: Coordinate(x: x, y: y))
                    galaxies.append(galaxy)
                }
            }
        }

        return galaxies
    }

    private func getGalaxyPairs(_ galaxies: [Galaxy]) -> [GalaxyPair] {
        var galaxyPairs = [GalaxyPair]()
        for i in 0 ..< galaxies.count {
            for j in i + 1 ..< galaxies.count {
                galaxyPairs.append(GalaxyPair(id1: i, id2: j))
            }
        }

        return galaxyPairs
    }
}
