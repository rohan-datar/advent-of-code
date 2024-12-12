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

enum Direction: CaseIterable {
    case up, down, left, right
}

struct Position {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    mutating func move(direction: Direction) {
        switch direction {
        case .up:
            self.x -= 1
        case .down:
            self.x += 1
        case .right:
            self.y += 1
        case .left:
            self.y -= 1
        }
    }

    func next(direction: Direction) -> Position {
        var nextPos = self
        nextPos.move(direction: direction)
        return nextPos
    }

    func neighbors() -> [Position] {
        var neighbors: [Position] = []
        for dir in Direction.allCases {
            neighbors.append(self.next(direction: dir))
        }

        return neighbors
    }

    func upRight() -> (Position, Position) {
        return (self.next(direction: Direction.up), self.next(direction: Direction.right))
    }

    func downLeft() -> (Position, Position) {
        return (self.next(direction: Direction.down), self.next(direction: Direction.left))
    }

    func isOutOfBounds(map: [[Character]]) -> Bool {
        return (x >= map.count || x < 0 || y >= map[x].count || y < 0)
    }

}

extension Position: Equatable {
    // comparison operators
    static func == (lhs: Position, rhs: Position) -> Bool {
        return
            lhs.x == rhs.x &&
            lhs.y == rhs.y
    }

    static func != (lhs: Position, rhs: Position) -> Bool {
        return
            lhs.x != rhs.x ||
            lhs.y != rhs.y
    }
}

extension Position: CustomStringConvertible {
    var description: String {
        return "(x: \(x), y: \(y))"
    }
}

func fillRegion(map: [[Character]],  start: Position, seen: inout [Position]) -> [Position] {
    let plant = map[start.x][start.y]
    var region: [Position] = []

    var locations: [Position] = [start]
    while (!locations.isEmpty) {
        let loc = locations.removeFirst()
        region.append(loc)
        for neighbor in loc.neighbors() {
            if neighbor.isOutOfBounds(map: map) {
                continue
            }
            if seen.contains(where: { $0 == neighbor }) {
                continue
            }
            let newPlant = map[neighbor.x][neighbor.y]
            if newPlant == plant {
                seen.append(neighbor)
                locations.append(neighbor)
            }
        }
    }
    return region
}

func getPrice(region: [Position]) -> Int {
    let area = region.count
    var corners = 0
    for plot in region {
        for dir in Direction.allCases {
            let neighbor = plot.next(direction: dir)
            if (!region.contains(where: { $0 == neighbor })) {
                perimeter += 1
            }
        }
    }

    return area * perimeter
}

func isCorner(map: [[Character]], plot: Position) -> Bool {
    // if at least two neighbors are out of bounds we have a corner
    var oob = 0
    for neighbor in plot.neighbors() {
        if neighbor.isOutOfBounds(map: map) {
            oob += 1
        }
    }
    if oob >= 2 { return true }

    // if two neighbors are the same but the space in between them is different, we have a corner

}

func getPrice2(region: [Position]) -> Int {
    let area = region.count
}


guard let chars = readChars(fromFilePath: "input") else {
    print("couldn't read input")
    exit(1)
}

var seen: [Position] = []
var regions: [[Position]] = []
for x in 0..<chars.count {
    for y in 0..<chars[x].count {
        if seen.contains(where: { $0 == Position(x: x, y: y) }) {
            continue
        }
        seen.append(Position(x: x, y: y))
        let region = fillRegion(map: chars, start: Position(x: x, y: y), seen: &seen)
        print("region \(chars[x][y]): \(region.count)")
        regions.append(region)
    }
}
var totalPrice = 0
for region in regions {
    totalPrice += getPrice(region: region)
}


print(totalPrice)
