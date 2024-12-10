import Foundation

/// read the input file
/// and return the array of lines in the file
func readChars(fromFilePath: String) -> [[Int]]? {
    let input = try? String(contentsOfFile: fromFilePath, encoding: String.Encoding.ascii)
    guard let input = input else {
        return nil
    }

    // split returns an [StringProtocol], not [String], so we cast them.
    let lines = input.split(separator: "\n").map({ String($0) })
    var nums = [[Int]]()

    for line in lines {
        var line_nums: [Int] = []

        for line_char in line {
            guard let num = line_char.wholeNumberValue else {
                return nil
            }
            line_nums.append(num)
        }

        nums.append(line_nums)
    }

    return nums
}

enum Direction {
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

    func isOutOfBounds(map: [[Int]]) -> Bool {
        return (x >= map.count || x < 0 || y >= map[x].count || y < 0)
    }
}

func walkTrails(map: [[Int]], pos: Position, prev: Int, seen: inout [Position]) -> Int {
    // if we're out of bounds this isn't a valid trail
    if pos.isOutOfBounds(map: map) {
        return 0
    }
    // if the previous value isn't one less than the current value, this isn't a valid trail
    let this = prev + 1
    if (map[pos.x][pos.y] != this) {
        return 0
    }
    // if we see 9, we've reached the end of the trail!
    if (map[pos.x][pos.y] == 9) {
        if (seen.contains(where: { $0.x == pos.x && $0.y == pos.y })) {
            return 0
        }
        seen.append(pos)
        return 1
    }

    // return the sum of all possible trails from this point
    return walkTrails(map: map, pos: pos.next(direction: Direction.up), prev: this, seen: &seen) + walkTrails(map: map, pos: pos.next(direction: Direction.down), prev: this, seen: &seen) + walkTrails(map: map, pos: pos.next(direction: Direction.left), prev: this, seen: &seen) + walkTrails(map: map, pos: pos.next(direction: Direction.right), prev: this, seen: &seen)
}

func walkTrails2(map: [[Int]], pos: Position, prev: Int) -> Int {
    // if we're out of bounds this isn't a valid trail
    if pos.isOutOfBounds(map: map) {
        return 0
    }
    // if the previous value isn't one less than the current value, this isn't a valid trail
    let this = prev + 1
    if (map[pos.x][pos.y] != this) {
        return 0
    }
    // if we see 9, we've reached the end of the trail!
    if (map[pos.x][pos.y] == 9) {
        return 1
    }

    // return the sum of all possible trails from this point
    return walkTrails2(map: map, pos: pos.next(direction: Direction.up), prev: this) + walkTrails2(map: map, pos: pos.next(direction: Direction.down), prev: this) + walkTrails2(map: map, pos: pos.next(direction: Direction.left), prev: this) + walkTrails2(map: map, pos: pos.next(direction: Direction.right), prev: this)
}

func findTrailHeads(map: [[Int]]) -> [Position] {
    var heads: [Position] = []
    for x in 0..<map.count {
        for y in 0..<map[x].count {
            if(map[x][y] == 0) {
                heads.append(Position(x: x, y: y))
            }
        }
    }

    return heads
}


guard let nums = readChars(fromFilePath: "input") else {
    print("couldn't read input")
    exit(1)
}

let heads = findTrailHeads(map: nums)

var sum = 0
var sum2 = 0
for head in heads {
    var seen: [Position] = []
    let score = walkTrails(map: nums, pos: head, prev: -1, seen: &seen)
    sum += score
    let rating = walkTrails2(map: nums, pos: head, prev: -1)
    sum2 += rating
}

print("score: \(sum)")
print("rating: \(sum2)")
