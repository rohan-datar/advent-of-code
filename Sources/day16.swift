import Foundation
import Collections


/// read the input file
/// and return the array of lines in the file
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
    var facing: Direction
    var cost: Int
    var prev: State?

    init(pos: Position, facing: Direction, cost: Int, prev: State?) {
        self.pos = pos
        self.facing = facing
        self.cost = cost
        self.prev = prev
    }

    func next() -> Position {
        return self.pos.next(dir: self.facing)
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

func deerScore(map: [[Character]], start: Position, startDir: Direction, end: Position) -> [State]? {
    var queue: Heap<State> = []
    var visited: [State] = []
    var paths: [State] = []
    var highscore = Int.max

    queue.insert(State(pos: start, facing: startDir, cost: 0, prev: nil))
    while !queue.isEmpty {
        guard let current = queue.popMin() else {
            return nil
        }

        if current.cost > highscore {
            break
        }
        if current.pos == end {
            highscore = current.cost
            paths.append(current)
        }

        if visited.contains(where: { $0.pos == current.pos && $0.facing == current.facing }) {
            if  let vcost = visited.first(where: { $0.pos == current.pos && $0.facing == current.facing })?.cost {
                if vcost < current.cost {
                    continue
                }
            } else {
                fatalError("what")
            }
        } else {
            visited.append(current)
            let fwdPos = current.next()
            // print("fwd: \(fwdPos)")
            // if (!fwdPos.isOutOfBounds(map: map)) { print(map[fwdPos.x][fwdPos.y]) }
            if (!fwdPos.isOutOfBounds(map: map) && map[fwdPos.x][fwdPos.y] != "#") {
                queue.insert(State(pos: fwdPos, facing: current.facing, cost: current.cost + 1, prev: current))
            }

            let leftPos = current.pos.next(dir: current.facing.turnLeft())
            // print("left: \(leftPos)")
            // if (!fwdPos.isOutOfBounds(map: map)) { print(map[fwdPos.x][fwdPos.y]) }
            if (!leftPos.isOutOfBounds(map: map) && map[leftPos.x][leftPos.y] != "#") {
                queue.insert(State(pos: leftPos, facing: current.facing.turnLeft(), cost: current.cost + 1001, prev: current))
            }

            let rightPos = current.pos.next(dir: current.facing.turnRight())
            // print("right: \(rightPos)")
            if (!rightPos.isOutOfBounds(map: map) && map[rightPos.x][rightPos.y] != "#") {
                queue.insert(State(pos: rightPos, facing: current.facing.turnRight(), cost: current.cost + 1001, prev: current))
            }
        }
    }
    return paths
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
          forResource: "test2",
          withExtension: "txt",
          subdirectory: "Day16")

        guard let inputURL,
          let inputData = try? String(contentsOf: inputURL, encoding: .utf8)
        else {
          fatalError("Couldn't find file 'input' in the 'Data' directory.")
        }

        let chars = readChars(input: inputData)
        // for line in chars {
        //     print(String(line))
        // }

        guard let start = findStartingPosition(map: chars) else {
            print("couldn't find starting position")
            exit(1)
        }

        guard let end = findEndingPosition(map: chars) else {
            print("couldn't find ending position")
            exit(1)
        }

        guard let paths = deerScore(map: chars, start: start, startDir: Direction.right, end: end) else {
            print("could not find path")
            exit(1)
        }

        print("score: \(paths[0].cost)")

        var points: Set<Position> = []
        for path in paths {
            var curr = path
            while let prev = curr.prev {
                points.insert(curr.pos)
                curr = prev
            }
        }

        var finalMap = chars
        for x in 0..<chars.count {
            for y in 0..<chars[x].count {
                if points.contains(Position(x: x, y: y)) {
                    finalMap[x][y] = "O"
                } else {
                    finalMap[x][y] = chars[x][y]
                }
            }
        }

        for line in finalMap {
            print(String(line))
        }

        print("points: \(points.count)")
    }
}
