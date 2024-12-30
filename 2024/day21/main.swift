import Foundation

/// read the input file
/// and return the array of lines in the file
func readLines(fromFilePath: String) -> [String]? {
  let input = try? String(contentsOfFile: fromFilePath, encoding: String.Encoding.ascii)
  guard let input = input else {
    return nil
  }

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

    func toString() -> String {
        switch self {
        case .up:
            return "^"
        case .right:
            return ">"
        case .down:
            return "v"
        case .left:
            return "<"
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

class State {
    var pos: Position
    var path: String

    init(pos: Position, path: String) {
        self.pos = pos
        self.path = path
    }

}

extension Position: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

let numPad: Dictionary<Position,  String> = [
    Position(x: 0, y: 0): "7", Position(x: 0, y: 1): "8", Position(x: 0, y: 2): "9",
    Position(x: 1, y: 0): "4", Position(x: 1, y: 1): "5", Position(x: 1, y: 2): "6",
    Position(x: 2, y: 0): "1", Position(x: 2, y: 1): "2", Position(x: 2, y: 2): "3",
                               Position(x: 3, y: 1): "0", Position(x: 3, y: 2): "A"
]

let dirPad: Dictionary<Position, String> = [
                               Position(x: 0, y: 1): "^", Position(x: 0, y: 2): "A",
    Position(x: 1, y: 0): "<", Position(x: 1, y: 1): "v", Position(x: 1, y: 2): ">"
]


func createGraph(pad: Dictionary<Position, String>, invalid: Position, paths: inout Dictionary<String, String>) {
    for (pos, label) in pad {
        for (p, l) in pad {
            var path = ""
            if (pos.y - p.y) > 0 {
                path += String(repeating: "<", count: (pos.y - p.y))
            }
            if (p.x - pos.x) > 0 {
                path += String(repeating: "v", count: (p.x - pos.x))
            }
            if (pos.x - p.x) > 0 {
                path += String(repeating: "^", count: (pos.x - p.x))
            }
            if (p.y - pos.y) > 0 {
                path += String(repeating: ">", count: (p.y - pos.y))
            }
            if (Position(x: pos.x, y: p.y) == invalid) || (Position(x: p.x, y: pos.y) == invalid) {
                path = String(path.reversed())
            }
            paths[label + l] = path + "A"
        }
    }
}

func convertToPath(sequence: String, paths: Dictionary<String, String>) -> String {
    var conversion = ""
    var prev: Character = "A"
    for char in sequence {
        conversion += paths[String(prev) + String(char)]!
        prev = char
    }
    return conversion
}

struct Sequence: Hashable {
    var seq: String
    var iter: Int

    init(seq: String, iter: Int) {
        self.seq = seq
        self.iter = iter
    }

    static func == (lhs: Sequence, rhs: Sequence) -> Bool {
        return (lhs.seq == rhs.seq &&
                lhs.iter == rhs.iter)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(seq)
        hasher.combine(iter)
    }
}

func getLength(sequence: String, iterations: Int, seen: inout Dictionary<Sequence, Int>, first: Bool) -> Int {
    if let len = seen[Sequence(seq: sequence, iter: iterations)] {
        return len
    }
    if iterations == 0 {
        return sequence.count
    }

    var prev: Character = "A"
    var length = 0
    var graph: Dictionary<String, String> = [:]
    if first {
        graph = numPaths
    } else {
        graph = dirPaths
    }
    for char in sequence {
        let conversion = graph[String(prev) + String(char)]!
        length += getLength(sequence: conversion, iterations: iterations - 1, seen: &seen, first: false)
        prev = char
    }
    seen[Sequence(seq: sequence, iter: iterations)] = length
    return length
}



var numPaths: Dictionary<String, String> = [:]
var dirPaths: Dictionary<String, String> = [:]
createGraph(pad: numPad, invalid: Position(x: 3, y: 0), paths: &numPaths)
createGraph(pad: dirPad, invalid: Position(x: 0, y: 0), paths: &dirPaths)


guard let lines = readLines(fromFilePath: "input") else {
    print("couldn't read file")
    exit(1)
}

var sum = 0
var seen: Dictionary<Sequence, Int> = [:]
for line in lines {
    let len = getLength(sequence: line, iterations: 26, seen: &seen, first: true)
    let lineVal = Int(line.dropLast())!
    sum += len * lineVal
}
print(sum)
