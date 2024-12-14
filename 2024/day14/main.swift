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
        hasher.combine(x)
        hasher.combine(y)
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


class Robot {
    var startingPosition: Vector2
    var velocity: Vector2

    init(start: Vector2, v: Vector2) {
        self.startingPosition = start
        self.velocity = v
    }

    func finalPosition(iterations: Int, maxX: Int, maxY: Int) -> Vector2 {
        let final = self.startingPosition + (self.velocity * iterations)
        let modx = final.x % maxX
        let mody = final.y % maxY
        let normx = (maxX + modx) % maxX
        let normy = (maxY + mody) % maxY
        return Vector2(x: normx, y: normy)
    }
}

func initRobot(line: String) -> Robot {
    let parts = line.split(separator: " ")
    let pos = parts[0].split(separator: "=")[1].split(separator: ",")
    let vel = parts[1].split(separator: "=")[1].split(separator: ",")

    return Robot(start: Vector2(x: Int(pos[0])!, y: Int(pos[1])!), v: Vector2(x: Int(vel[0])!, y: Int(vel[1])!))
}

func getSafetyFactor(robots: [Robot], maxX: Int, maxY: Int, iterations: Int) -> Int {
    var finalPositions: [Vector2] = []
    let midX = maxX/2
    let midY = maxY/2
    for robot in robots {
        let pos = robot.finalPosition(iterations: iterations, maxX: maxX, maxY: maxY)
        // remove robots in the middle
        if (pos.x == midX) || (pos.y == midY) {
            continue
        }

        finalPositions.append(pos)
    }

    var q1 = 0
    var q2 = 0
    var q3 = 0
    var q4 = 0

    for pos in finalPositions {
        if (pos.x < midX) && (pos.y < midY) {
            q1 += 1
            continue
        }
        if (pos.x > midX) && (pos.y < midY) {
            q2 += 1
            continue
        }
        if (pos.x < midX) && (pos.y > midY) {
            q3 += 1
            continue
        }
        if (pos.x > midX) && (pos.y > midY) {
            q4 += 1
            continue
        }
    }

    return q1 * q2 * q3 * q4
}

func findChristmasTree(robots: [Robot], maxX: Int, maxY: Int) -> Int {
    var it = 0
    while true {
        var finalPositions: Set<Vector2> = Set()
        for robot in robots {
            let pos = robot.finalPosition(iterations: it, maxX: maxX, maxY: maxY)
            finalPositions.insert(pos)
        }
        if (finalPositions.count == robots.count) {
            return it
        }
        it += 1
    }
}

func printChristmasTree(robots: [Robot], maxX: Int, maxY: Int) {
    var positions: Set<Vector2> = Set()
    var it = 0
    while true {
        var finalPositions: Set<Vector2> = Set()
        for robot in robots {
            let pos = robot.finalPosition(iterations: it, maxX: maxX, maxY: maxY)
            finalPositions.insert(pos)
        }
        if (finalPositions.count == robots.count) {
            positions = finalPositions
            break
        }
        it += 1
    }

    for x in 0..<maxX {
        var line: [Character] = []
        for y in 0..<maxY {
            if positions.contains(Vector2(x: x, y: y)) {
                line.append("*")
                continue
            }
            line.append(".")
        }
        print(String(line))
    }
}

guard let lines = readLines(fromFilePath: "input") else {
    print("couldn't read file")
    exit(1)
}

let maxX = 101
let maxY = 103
let iterations = 100
var robots: [Robot] = []
for line in lines {
    let robo = initRobot(line: line)
    robots.append(robo)
}

print(getSafetyFactor(robots: robots, maxX: maxX, maxY: maxY, iterations: iterations))
print(findChristmasTree(robots: robots, maxX: maxX, maxY: maxY))
printChristmasTree(robots: robots, maxX: maxX, maxY: maxY)
