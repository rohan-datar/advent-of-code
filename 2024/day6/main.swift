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
        var nextPos = self
        nextPos.move(currentDirection: currentDirection)
        return nextPos
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
            lhs.y != rhs.y
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
    var map: [[Character]]
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
        visited.append((currentPosition.x, currentPosition.y))
        self.map = map
    }


    func reachedEnd() -> Bool {
        // print("checking: \(currentPosition.x), \(currentPosition.y) \(currentDirection)")
        let nextPos = currentPosition.next(currentDirection: currentDirection)
        return (nextPos.x >= map.count || nextPos.x < 0 || nextPos.y >= map[nextPos.x].count || nextPos.y < 0)
    }

    func advance() {
        var nextPos = currentPosition.next(currentDirection: currentDirection)
        while (map[nextPos.x][nextPos.y] == "#") {
            self.currentDirection.turn()
            nextPos = currentPosition.next(currentDirection: currentDirection)
        }

        self.currentPosition.move(currentDirection: self.currentDirection)


        if (!visited.contains(where: { $0 == (currentPosition.x, currentPosition.y) })) {
            visited.append((currentPosition.x, currentPosition.y))
        }

        map[currentPosition.x][currentPosition.y] = "X"

    }

    func advanceWithoutVisit() {
        var nextPos = currentPosition.next(currentDirection: currentDirection)
        while (self.map[nextPos.x][nextPos.y] == "#") {
            self.currentDirection.turn()
            nextPos = currentPosition.next(currentDirection: currentDirection)
        }

        self.currentPosition.move(currentDirection: self.currentDirection)
    }
}

func addObstruction(chars: [[Character]], x: Int, y: Int) -> [[Character]] {
    var newChars = chars
    newChars[x][y] = "#"
    return newChars
}

func findLoop(chars: [[Character]]) async -> Bool{
    let map1 = Map(map: chars)
    let map2 = Map(map: chars)

    while true {
        map1.advanceWithoutVisit()
        if (map1.reachedEnd()) {
            return false
        }

        map2.advanceWithoutVisit()
        if (map2.reachedEnd()) {
            return false
        }

        map2.advanceWithoutVisit()
        if (map2.reachedEnd()) {
            return false
        }

        if ((map2.currentPosition == map1.currentPosition) && (map2.currentDirection == map1.currentDirection)) {
            return true
        }
    }
}

func findObstructions(map: Map) async -> Int {
    let obs = await withTaskGroup(of: Bool.self) { group in
        for (x, y) in map.visited {
            if ((x, y) == map.visited[0]) {
                continue
            }
            let charsWithOb = addObstruction(chars: map.map, x: x, y: y)
            group.addTask { await findLoop(chars: charsWithOb) }
        }

        var loops = 0
        for await isLoop in group {
            if isLoop {
                loops += 1
            }
        }

        return loops
    }
    return obs
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

let obstructions = await findObstructions(map: map)


print("obstructions: \(obstructions)")
