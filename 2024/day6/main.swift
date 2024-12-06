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

struct Position {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    mutating func move(currentDirection: movementDirection) {
        switch currentDirection {
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

    func next(currentDirection: movementDirection) -> Position {
        switch currentDirection {
        case .up:
            return Position(x: self.x - 1, y: self.y)
        case .down:
            return Position(x: self.x + 1, y: self.y)
        case .right:
            return Position(x: x, y: self.y + 1)
        case .left:
            return Position(x: x, y: self.y - 1)
        }
    }
}

enum movementDirection {
    case up
    case down
    case left
    case right

    mutating func turn()  {
        switch self {
        case .up:
            self = .right
        case .down:
            self = .left
        case .left:
            self = .up
        case .right:
            self = .down
        }
    }

}

func strToDirection(dirChar: Character) -> movementDirection? {
    switch dirChar {
    case "^":
        return .up
    case ">":
        return .right
    case "v":
        return .down
    case "<":
        return .left
    default:
        return nil
    }
}

class Map {
    let map: [[Character]]
    var visited: [(Int, Int)]
    var currentPosition: Position
    var currentDirection: movementDirection

    init(map: [[Character]]) {
        var startPos = Position(x: 0, y: 0)
        var startdir = movementDirection.up
        for x in 0..<map.count {
            for y in 0..<map[x].count {
                if ((map[x][y] == "^") || (map[x][y] == "v") || (map[x][y] == "<") || (map[x][y] == ">")) {
                    startPos = Position(x: x, y: y)
                    startdir = strToDirection(dirChar: map[x][y])!
                }
            }
        }

        self.currentDirection = startdir
        self.currentPosition = startPos
        self.visited = []
        self.map = map
    }


    func reachedEnd() -> Bool {
        let nextPos = currentPosition.next(currentDirection: currentDirection)
        return (nextPos.x >= map.count || nextPos.x < 0 || nextPos.y >= map[nextPos.x].count || nextPos.y < 0)
    }

    func advance() {
        let nextPos = currentPosition.next(currentDirection: currentDirection)
        if (map[nextPos.x][nextPos.y] == "#") {
            self.currentDirection.turn()
        }


        if (!visited.contains(where: { $0 == (currentPosition.x, currentPosition.y) })) {
            visited.append((currentPosition.x, currentPosition.y))
        }

        self.currentPosition.move(currentDirection: self.currentDirection)
    }
}

guard let chars = readChars(fromFilePath: "input") else {
    print("couldn't read input")
    exit(1)
}

let map = Map(map: chars)
while !map.reachedEnd() {
    map.advance()
}

print("visited: \(map.visited.count)")
