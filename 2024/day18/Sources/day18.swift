import Foundation
import Collections


/// read the input file
/// and return the array of lines in the file
func readLines(input: String) -> [String] {
    // split returns an [StringProtocol], not [String], so we cast them.
    let lines = input.split(separator: "\n").map({ String($0) })
    return lines
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

func dijkstra(map: [[Character]], start: Position, end: Position) -> Int? {
    var queue: Heap<State> = []
    var visited: [State] = []

    queue.insert(State(pos: start, cost: 0, prev: nil))
    while !queue.isEmpty {
        guard let current = queue.popMin() else {
            return nil
        }

        if current.pos == end {
            return current.cost
        }

        if visited.contains(where: { $0.pos == current.pos && $0.cost <= current.cost }) {
            continue
        }
        if !visited.contains(where: { $0.pos == current.pos }) {
            visited.append(current)
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


func readCoords(coordLine: String) -> Position {
    let coords = coordLine.split(separator: ",")
    let x = Int(coords[1])!
    let y = Int(coords[0])!
    return Position(x: x, y: y)
}

func createMap(corrupted: [Position]) -> [[Character]] {
    var map: [[Character]] = []
    for x in 0..<dimX+1 {
        map.append([])
        for y in 0..<dimY+1 {
            if corrupted.contains(Position(x: x, y: y)) {
                map[x].append("#")
            } else {
                map[x].append(".")
            }
        }
    }
    return map
}



let dimX = 70
let dimY = 70

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

        let lines = readLines(input: inputData)
        var corrupted: [Position] = []
        for lineNum in 0..<1024 {
            let pos = readCoords(coordLine: lines[lineNum])
            corrupted.append(pos)
        }

        let map = createMap(corrupted: corrupted)

        for line in map {
            print(String(line))
        }
        guard let score = dijkstra(map: map, start: Position(x: 0, y: 0), end: Position(x: dimX, y: dimY)) else {
            print("could not find path")
            exit(1)
        }

        print("score: \(score)")


    }
}
