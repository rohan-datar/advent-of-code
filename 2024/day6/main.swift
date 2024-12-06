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

extension Position: Equatable {
    static func == (lhs: Position, rhs: Position) -> Bool {
        return
            lhs.x == rhs.x &&
            lhs.y == rhs.y
    }

    static func != (lhs: Position, rhs: Position) -> Bool {
        return
            lhs.x != rhs.x ||
            lhs.y == rhs.y
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

    func turned() -> movementDirection  {
        switch self {
        case .up:
            return .right
        case .down:
            return .left
        case .left:
            return .up
        case .right:
            return .down
        }
    }
    func toChar() -> Character {
        switch self {
        case .up:
            return "^"
        case .down:
            return "v"
        case .left:
            return "<"
        case .right:
            return ">"
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
    var map: [[Character]]
    var visited: [(Int, Int)]
    var currentPosition: Position
    var currentDirection: movementDirection
    // var visitedWithDir: [(Int, Int, movementDirection)]

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
        visited.append((currentPosition.x, currentPosition.y))
        self.map = map
        // self.visitedWithDir = []
    }


    func reachedEnd() -> Bool {
        // print("checking: \(currentPosition.x), \(currentPosition.y) \(currentDirection)")
        let nextPos = currentPosition.next(currentDirection: currentDirection)
        return (nextPos.x >= map.count || nextPos.x < 0 || nextPos.y >= map[nextPos.x].count || nextPos.y < 0)
    }

    func advance() {
        let nextPos = currentPosition.next(currentDirection: currentDirection)
        if (map[nextPos.x][nextPos.y] == "#") {
            self.currentDirection.turn()
        }

        self.currentPosition.move(currentDirection: self.currentDirection)


        if (!visited.contains(where: { $0 == (currentPosition.x, currentPosition.y) })) {
            visited.append((currentPosition.x, currentPosition.y))
        }

        map[currentPosition.x][currentPosition.y] = "X"

    }

    func advanceWithoutVisit() {
        let nextPos = currentPosition.next(currentDirection: currentDirection)
        if (self.map[nextPos.x][nextPos.y] == "#") {
            self.currentDirection.turn()
        }

        self.currentPosition.move(currentDirection: self.currentDirection)
    }
}

func addObstruction(chars: [[Character]], x: Int, y: Int) -> [[Character]] {
    // if (x >= map.map.count || x < 0 || y >= map.map[x].count || y < 0) {
    //     return nil
    // }
    var newChars = chars
    newChars[x][y] = "#"
    return newChars
}

guard let chars = readChars(fromFilePath: "input") else {
    print("couldn't read input")
    exit(1)
}
let size = chars.count * chars[0].count


let map = Map(map: chars)
repeat {
    map.advance()
} while !map.reachedEnd()


print("visited: \(map.visited.count)")

var obstructions = 0
var i = 0;
for x in 0..<chars.count {
    for y in 0..<chars[x].count {
        if ((x, y) == map.visited[0]) {
            continue
        }
    // print("i: \(i)")
    let charsWithOb = addObstruction(chars: chars, x: x, y: y)
    let newMap1 = Map(map: charsWithOb)
    let newMap2 = Map(map: charsWithOb)
    print("current: \(x), \(y)")
    // if (newMap.willLoop()) {
    //     print("found loop")
    //     obstructions += 1
    // }

    repeat {
        newMap1.advanceWithoutVisit()
        if (newMap1.reachedEnd()) {
            break
        }

        newMap2.advanceWithoutVisit()
        if (newMap2.reachedEnd()) {
            break
        }

        newMap2.advanceWithoutVisit()
        if (newMap2.reachedEnd()) {
            break
        }

        if (newMap2.currentPosition == newMap1.currentPosition) {
            obstructions += 1
            break
        }
    } while true

    }
}



print("obstructions: \(obstructions)")
