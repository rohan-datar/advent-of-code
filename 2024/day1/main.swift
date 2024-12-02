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

// create a class to hold the two lists of numbers
class LocationIDs {
    var left: [Int]
    var right: [Int]

    init(left: [Int], right: [Int]) {
        self.left = left
        self.right = right
    }

    enum DataError: Error {
        case lengthMismatch
    }

    func getTotalDistance() throws -> Int {
        if left.count != right.count {
            throw DataError.lengthMismatch
        }
        self.left.sort()
        self.right.sort()
        var total = 0


        for i in 0...left.count-1 {
            total += (abs(self.left[i] - self.right[i]))
        }

        return total
    }

    func getSimilarityScore() -> Int {
        var score = 0

        for l in left {
            var count = 0
            for r in right {
                if l == r {
                    count += 1
                }
            }

            score += (l * count)
        }

        return score
    }
}

enum ParseError: Error {
    case notANumber
}

func parseLines(lines: [String]) throws -> LocationIDs {
    var leftNums: [Int] = []
    var rightNums: [Int] = []
    for line in lines {
        let numbers = line.split(separator: "   ").map({ String($0) })
        guard let leftNum = Int(numbers[0]) else {
            throw ParseError.notANumber
        }
        leftNums.append(leftNum)
        guard let rightNum = Int(numbers[1]) else {
            throw ParseError.notANumber
        }
        rightNums.append(rightNum)
    }

    return LocationIDs(left: leftNums, right: rightNums)
}

guard let lines = readLines(fromFilePath: "input") else {
    print("couldn't read input")
    exit(1)
}

let locations = try? parseLines(lines: lines)
guard let locations = locations else {
    print("couldn't parse input")
    exit(1)
}

let totalDistance = try? locations.getTotalDistance()
guard let totalDistance = totalDistance else {
    print("couldn't calculate distance")
    exit(1)
}

print("distance: \(totalDistance)")

let similarity = locations.getSimilarityScore()
print("similarity: \(similarity)")
