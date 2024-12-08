import Foundation


/// read the input file
/// and return the array of lines in the file
func readChars(fromFilePath: String) -> [[Character]]? {
    let input = try? String(contentsOfFile: fromFilePath, encoding: String.Encoding.ascii)
    guard let input = input else {
        return nil
    }

    // split returns an [StringProtocol], not [String], so we cast them.
    let lines = input.split(separator: "\n").map({ String($0) })
    var chars = [[Character]]()

    for line in lines {
        var line_chars: [Character] = []

        for line_char in line {
            line_chars.append(line_char)
        }

        chars.append(line_chars)
    }

    return chars
}

class Vector2 {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

infix operator * : MultiplicationPrecedence

extension Vector2 {
    // Vector negation
    static prefix func - (vector: Vector2) -> Vector2 {
        return Vector2(x: -vector.x, y: -vector.y)
    }

    // Vector addition
    static func + (left: Vector2, right: Vector2) -> Vector2 {
        return Vector2(x: left.x + right.x, y: left.y + right.y)
    }

    // Vector subtraction
    static func - (left: Vector2, right: Vector2) -> Vector2 {
        return left + (-right)
    }

    // Vector addition assignment
    static func += (left: inout Vector2, right: Vector2) {
        left = left + right
    }

    // Vector subtraction assignment
    static func -= (left: inout Vector2, right: Vector2) {
        left = left - right
    }

    // Scalar-vector multiplication
    static func * (left: Int, right: Vector2) -> Vector2 {
        return Vector2(x: right.x * left, y: right.y * left)
    }

    static func * (left: Vector2, right: Int) -> Vector2 {
        return Vector2(x: left.x * right, y: left.y * right)
    }

    static func *= (left: inout Vector2, right: Int) {
        left = left * right
    }
}

extension Vector2: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Vector2: Equatable {
    // comparison operators
    static func == (lhs: Vector2, rhs: Vector2) -> Bool {
        return
            lhs.x == rhs.x &&
            lhs.y == rhs.y
    }

    static func != (lhs: Vector2, rhs: Vector2) -> Bool {
        return
            lhs.x != rhs.x ||
            lhs.y != rhs.y
    }
}

extension Vector2: CustomStringConvertible {
    var description: String {
        return "(x: \(x), y: \(y))"
    }
}

extension Vector2 {
    func isOutOfBounds(map: [[Character]]) -> Bool {
        return (x >= map.count || x < 0 || y >= map[x].count || y < 0)
    }
}


func getAntennaPositions(map: [[Character]]) -> Dictionary<Character, [Vector2]> {
    var positions: [Character: [Vector2]] = [:]
    for x in 0..<map.count {
        for y in 0..<map[x].count {
            if (map[x][y] != ".") {
                positions[map[x][y], default: []].append(Vector2(x: x, y: y))
            }
        }
    }

    return positions
}

func getAntinodePositionsForFrequency(antennas: [Vector2], map: [[Character]]) -> [(Int, Int)] {
    var nodes: [(Int, Int)] = []
    for i in 0..<antennas.count {
        for j in i+1..<antennas.count {
            // grab the two antennas
            let a = antennas[i]
            let b = antennas[j]
            let node1 = a + ((b - a) * 2)
            let node2 = b + ((a - b) * 2)

            if !node1.isOutOfBounds(map: map) {
                if(!nodes.contains(where: { $0 == (node1.x, node1.y) })) {
                    nodes.append((node1.x, node1.y))
                }
            }

            if !node2.isOutOfBounds(map: map) {
                if(!nodes.contains(where: { $0 == (node2.x, node2.y) })) {
                    nodes.append((node2.x, node2.y))
                }
            }
        }
    }

    return nodes
}

func countUniqueAntinodes(antennaMap: Dictionary<Character, [Vector2]>, map: [[Character]]) -> Int {
    var nodes: [(Int, Int)] = []
    for (_, locations) in antennaMap {
        let antinodes = getAntinodePositionsForFrequency(antennas: locations, map: map)
        for node in antinodes {
            if (!nodes.contains(where: { $0 == node })) {
                nodes.append(node)
            }
        }
    }

    return nodes.count
}

func getAntinodePositionsForFrequency2(antennas: [Vector2], map: [[Character]]) -> [(Int, Int)] {
    var nodes: [(Int, Int)] = []
    for i in 0..<antennas.count {
        for j in i+1..<antennas.count {
            // grab the two antennas
            let a = antennas[i]
            let b = antennas[j]
            let dir1 = b - a
            let dir2 = a - b

            var node1 = a + dir1
            var node2 = b + dir2

            while !node1.isOutOfBounds(map: map) {
                if(!nodes.contains(where: { $0 == (node1.x, node1.y) })) {
                    nodes.append((node1.x, node1.y))
                }
                node1 += dir1
            }

            while !node2.isOutOfBounds(map: map) {
                if(!nodes.contains(where: { $0 == (node2.x, node2.y) })) {
                    nodes.append((node2.x, node2.y))
                }
                node2 += dir2
            }
        }
    }

    return nodes
}

func countUniqueAntinodes2(antennaMap: Dictionary<Character, [Vector2]>, map: [[Character]]) -> Int {
    var nodes: [(Int, Int)] = []
    for (_, locations) in antennaMap {
        let antinodes = getAntinodePositionsForFrequency2(antennas: locations, map: map)
        for node in antinodes {
            if (!nodes.contains(where: { $0 == node })) {
                nodes.append(node)
            }
        }
    }

    return nodes.count
}

guard let chars = readChars(fromFilePath: "input") else {
    print("couldn't read input")
    exit(1)
}

let antennaMap = getAntennaPositions(map: chars)
let antinodes1 = countUniqueAntinodes(antennaMap: antennaMap, map: chars)
print("antinodes1: \(antinodes1)")

let antinodes2 = countUniqueAntinodes2(antennaMap: antennaMap, map: chars)
print("antinodes2: \(antinodes2)")
