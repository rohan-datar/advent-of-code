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

enum ParseError: Error {
    case notANumber
}


func isSafe(report: [Int]) -> Bool {
    // check if this is an increasing sequence or not
    var increasing = true
    if report[0] > report[1] {
        increasing = false
    }
    for i in 1..<report.count {
        if (increasing && report[i] < report[i-1]) || (!increasing && report[i] > report[i-1]) {
            // print("unsafe")
            return false
        }
        let diff = abs(report[i] - report[i-1])
        if diff < 1 || diff > 3 {
            // print("unsafe")
            return false
        }
    }
    // print("safe")

    return true
}

func isSafeWithTolerance(report: [Int]) -> Bool {
    // check if this is an increasing sequence or not
    var increasing = true
    if report[0] > report[1] {
        increasing = false
    }
    for i in 1..<report.count {
        if (increasing && report[i] < report[i-1]) || (!increasing && report[i] > report[i-1]) {
            return checkTolerance(report: report)
        }
        let diff = abs(report[i] - report[i-1])
        if diff < 1 || diff > 3 {
            return checkTolerance(report: report)
        }
    }
    // print("safe")

    return true
}

func checkTolerance(report: [Int]) -> Bool {
    // try to remove each element
    print("report: \(report)")
    for i in 0..<report.count {
        var removed: [Int] = report as [Int]
        removed.remove(at: i)
        print("removed: \(removed)")
        if isSafe(report: removed) {
            return true
        }
    }

    return false
}

func readReport(line: String) throws -> [Int] {
    let nums = line.split(separator: " ").map({ String($0) })
    var report: [Int] = []
    for num in nums {
        guard let repNum = Int(num) else {
            throw ParseError.notANumber
        }

        report.append(repNum)
    }

    return report
}

guard let lines = readLines(fromFilePath: "input") else {
    print("couldn't read input")
    exit(1)
}

var sum = 0
print(lines.count)
for line in lines {
    let report = try? readReport(line: line)
    guard let report = report else {
        print("couldn't parse line: \(line)")
        exit(1)
    }
    // print("line: \(line)")
    // print("report: \(report)")
    if isSafeWithTolerance(report: report) {
        sum += 1
    }
}

print(sum)
