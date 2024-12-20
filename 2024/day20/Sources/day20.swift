import Foundation
import Collections


/// read the input file
/// and return the array of characters in the file
func readChars(input: String) -> [[Character]] {
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

    func turnRight() -> Direction {
        switch self {
        case .up:
            return .right
        case .right:
            return .down
        case .down:
            return .left
        case .left:
            return .up
        }
    }

    func turnLeft() -> Direction {
        switch self {
        case .up:
            return .left
        case .right:
            return .up
        case .down:
            return .right
        case .left:
            return .down
        }
    }
}

struct Position {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    mutating func move(dir: Direction) {
        switch dir {
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

    func next(dir: Direction) -> Position {
        var nextPos = self
        nextPos.move(dir: dir)
        return nextPos
    }

    func isOutOfBounds(map: [[Character]]) -> Bool {
        return (x >= map.count || x < 0 || y >= map[x].count || y < 0)
    }

    func neighbors() -> [Position] {
        var neighbors: [Position] = []
        for dir in Direction.allCases {
            neighbors.append(self.next(dir: dir))
        }

        return neighbors
    }

    func distance(end: Position) -> Int {
        return abs(self.x - end.x) + abs(self.y - end.y)
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

extension Position: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

class State {
    var pos: Position
    var cost: Int
    var prev: State?

    init(pos: Position, cost: Int, prev: State?) {
        self.pos = pos
        self.cost = cost
        self.prev = prev
    }

}


extension State: Comparable {
    static func == (lhs: State, rhs: State) -> Bool {
        return lhs.cost == rhs.cost
    }

    static func < (lhs: State, rhs: State) -> Bool {
        return lhs.cost < rhs.cost
    }

    static func > (lhs: State, rhs: State) -> Bool {
        return lhs.cost > rhs.cost
    }
}

func dijkstra(map: [[Character]], start: Position, end: Position) -> State? {
    var queue: Heap<State> = []
    var visited: Set<Position> = []

    queue.insert(State(pos: start, cost: 0, prev: nil))
    while !queue.isEmpty {
        guard let current = queue.popMin() else {
            return nil
        }

        if current.pos == end {
            return current
        }

        if !visited.contains(current.pos) {
            visited.insert(current.pos)
            let upPos = current.pos.next(dir: Direction.up)
            if (!upPos.isOutOfBounds(map: map) && map[upPos.x][upPos.y] != "#") {
                queue.insert(State(pos: upPos, cost: current.cost + 1, prev: current))
            }
            let downPos = current.pos.next(dir: Direction.down)
            if (!downPos.isOutOfBounds(map: map) && map[downPos.x][downPos.y] != "#") {
                queue.insert(State(pos: downPos, cost: current.cost + 1, prev: current))
            }
            let leftPos = current.pos.next(dir: Direction.left)
            if (!leftPos.isOutOfBounds(map: map) && map[leftPos.x][leftPos.y] != "#") {
                queue.insert(State(pos: leftPos, cost: current.cost + 1, prev: current))
            }
            let rightPos = current.pos.next(dir: Direction.right)
            if (!rightPos.isOutOfBounds(map: map) && map[rightPos.x][rightPos.y] != "#") {
                queue.insert(State(pos: rightPos, cost: current.cost + 1, prev: current))
            }
        }
    }
    return nil
}

func getDistances(map: [[Character]], start: Position, end: Position) -> Dictionary<Position, Int>? {
    var queue: Heap<State> = []
    var visited: Set<Position> = []
    var dists: Dictionary<Position, Int> = [:]

    queue.insert(State(pos: start, cost: 0, prev: nil))
    while !queue.isEmpty {
        guard let current = queue.popMin() else {
            return nil
        }

        if current.pos == end {
            return dists
        }

        if !visited.contains(current.pos) {
            visited.insert(current.pos)
            dists[current.pos] = current.cost
            let upPos = current.pos.next(dir: Direction.up)
            if (!upPos.isOutOfBounds(map: map) && map[upPos.x][upPos.y] != "#") {
                queue.insert(State(pos: upPos, cost: current.cost + 1, prev: current))
            }
            let downPos = current.pos.next(dir: Direction.down)
            if (!downPos.isOutOfBounds(map: map) && map[downPos.x][downPos.y] != "#") {
                queue.insert(State(pos: downPos, cost: current.cost + 1, prev: current))
            }
            let leftPos = current.pos.next(dir: Direction.left)
            if (!leftPos.isOutOfBounds(map: map) && map[leftPos.x][leftPos.y] != "#") {
                queue.insert(State(pos: leftPos, cost: current.cost + 1, prev: current))
            }
            let rightPos = current.pos.next(dir: Direction.right)
            if (!rightPos.isOutOfBounds(map: map) && map[rightPos.x][rightPos.y] != "#") {
                queue.insert(State(pos: rightPos, cost: current.cost + 1, prev: current))
            }
        }
    }
    return nil
}


func validPositionsWithin(map: [[Character]], start: Position, dist: Int) -> [Position] {
    var positions: [Position] = []
    var locations: [Position] = [start]
    var seen: Set<Position> = []
    for _ in 0..<dist + 1 {
        for loc in locations {
            if (map[loc.x][loc.y] != "#") {
                positions.append(loc)
            }
            for neighbor in loc.neighbors() {
                if neighbor.isOutOfBounds(map: map) {
                    continue
                }
                if !seen.contains(neighbor) {
                    seen.insert(neighbor)
                    locations.append(neighbor)
                }
            }
        }
    }

    positions.removeFirst()// remove the start
    return positions
}


func findCheats(map: [[Character]], bestPath: Dictionary<Position, Int>, back: Dictionary<Position, Int>, bestTime: Int, cheatDistance: Int) -> Int {
    var cheats = 0
    for (loc, cost) in bestPath {
        for (locBack, costBack) in back {
            let direct = loc.distance(end: locBack)
            if direct <= cheatDistance {
                let cheatTime = cost + direct + costBack
                if (bestTime - cheatTime) >= 100 {
                    cheats += 1
                }
            }
        }
    }
    return cheats
}


func findStartingPosition(map: [[Character]]) -> Position? {
    for x in 0..<map.count {
        for y in 0..<map[x].count {
            if map[x][y] == "S" {
                return Position(x: x, y: y)
            }
        }
    }

    return nil
}

func findEndingPosition(map: [[Character]]) -> Position? {
    for x in 0..<map.count {
        for y in 0..<map[x].count {
            if map[x][y] == "E" {
                return Position(x: x, y: y)
            }
        }
    }

    return nil
}



@main
class Main {
    static func main() {
        let inputURL = Bundle.module.url(
          forResource: "input",
          withExtension: "txt",
          subdirectory: "Data")

        guard let inputURL,
          let inputData = try? String(contentsOf: inputURL, encoding: .utf8)
        else {
          fatalError("Couldn't find file 'input' in the 'Data' directory.")
        }

        let chars = readChars(input: inputData)

        guard let start = findStartingPosition(map: chars) else {
            print("couldn't find starting position")
            exit(1)
        }

        guard let end = findEndingPosition(map: chars) else {
            print("couldn't find ending position")
            exit(1)
        }


        guard let shortestPath = dijkstra(map: chars, start: start, end: end) else {
            print("couldn't find path")
            exit(1)
        }

        guard let path: Dictionary<Position, Int> = getDistances(map: chars, start: start, end: end) else {
            print("couldn't get dists")
            exit(1)
        }

        guard let pathBack: Dictionary<Position, Int> = getDistances(map: chars, start: end, end: start) else {
            print("couldn't get dists")
            exit(1)
        }

        let part1 = findCheats(map: chars, bestPath: path, back: pathBack, bestTime: shortestPath.cost, cheatDistance: 2)
        print("p1: \(part1)")

        let part2 = findCheats(map: chars, bestPath: path, back: pathBack, bestTime: shortestPath.cost, cheatDistance: 20)
        print("p1: \(part2)")

    }
}
