import Foundation

let KEYWORD = "XMAS"


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

func rightHorizontal(chars: [[Character]], i: Int, j: Int) -> Bool {
    let row = i
    var col = j
    if (col + KEYWORD.count > chars[row].count) {
        return false
    }
    for key_char in KEYWORD {
        if (chars[row][col] != key_char) {
            return false
        }
        col += 1
    }

    print("rightHorizontal")
    return true
}

func leftHorizontal(chars: [[Character]], i: Int, j: Int) -> Bool {
    let row = i
    var col = j
    if ((col + 1) - KEYWORD.count < 0) {
        return false
    }
    for key_char in KEYWORD {
        if (chars[row][col] != key_char) {
            return false
        }
        col -= 1
    }

    print("leftHorizontal")
    return true
}

func downVertical(chars: [[Character]], i: Int, j: Int) -> Bool {
    var row = i
    let col = j
    if (row + KEYWORD.count > chars.count) {
        return false
    }
    for key_char in KEYWORD {
        if (chars[row][col] != key_char) {
            return false
        }
        row += 1
    }

    print("downVertical")
    return true
}


func upVertical(chars: [[Character]], i: Int, j: Int) -> Bool {
    var row = i
    let col = j
    if ((row + 1) - KEYWORD.count < 0) {
        return false
    }
    for key_char in KEYWORD {
        if (chars[row][col] != key_char) {
            return false
        }
        row -= 1
    }

    print("upVertical")
    return true
}

func downRight(chars: [[Character]], i: Int, j: Int) -> Bool {
    var row = i
    var col = j
    if (row + KEYWORD.count > chars.count) {  // Ensure there's enough space for the word downwards
        return false
    }
    if (col + KEYWORD.count > chars[row].count) {  // Ensure there's enough space for the word to the right
        return false
    }

    for key_char in KEYWORD {
        if (chars[row][col] != key_char) {
            return false
        }
        row += 1
        col += 1
    }

    print("downRight")
    return true
}

func downLeft(chars: [[Character]], i: Int, j: Int) -> Bool {
    var row = i
    var col = j
    if (row + KEYWORD.count > chars.count) {  // Ensure enough rows downward
        return false
    }
    if ((col + 1) - KEYWORD.count < 0) {  // Ensure enough columns to the left
        return false
    }

    for key_char in KEYWORD {
        if (chars[row][col] != key_char) {
            return false
        }
        row += 1
        col -= 1
    }

    print("downLeft")
    return true
}

func upRight(chars: [[Character]], i: Int, j: Int) -> Bool {
    var row = i
    var col = j
    if ((row + 1) - KEYWORD.count < 0) {  // Ensure enough rows upwards
        return false
    }
    if (col + KEYWORD.count > chars[row].count) {  // Ensure enough columns to the right
        return false
    }

    for key_char in KEYWORD {
        if (chars[row][col] != key_char) {
            return false
        }
        row -= 1
        col += 1
    }

    print("upRight")
    return true
}

func upLeft(chars: [[Character]], i: Int, j: Int) -> Bool {
    var row = i
    var col = j
    if ((row + 1) - KEYWORD.count < 0) {  // Ensure enough rows upwards
        return false
    }
    if ((col + 1) - KEYWORD.count < 0) {  // Ensure enough columns to the left
        return false
    }

    for key_char in KEYWORD {
        if (chars[row][col] != key_char) {
            return false
        }
        row -= 1
        col -= 1
    }

    print("upLeft")
    return true
}

func xMas(chars: [[Character]], row: Int, col: Int) -> Bool {
    if ((row - 1 < 0) || (col - 1 < 0) || (row + 1 >= chars.count) || (col + 1 >= chars[row].count)) {
        return false
    }
    var leftDiagonal = [chars[row][col], chars[row+1][col-1], chars[row-1][col+1]]
    leftDiagonal.sort()
    let leftDiagonalStr = String(leftDiagonal)
    if (leftDiagonalStr != "AMS") { return false }


    var rightDiagonal = [chars[row][col], chars[row-1][col-1], chars[row+1][col+1]]
    rightDiagonal.sort()
    let rightDiagonalStr = String(rightDiagonal)
    if (rightDiagonalStr != "AMS") { return false }

    return true
}

guard let chars = readChars(fromFilePath: "test") else {
    print("couldn't read input")
    exit(1)
}

var xmasSum = 0
var masSum = 0
for i in 0..<chars.count {
    for j in 0..<chars[i].count {
        if (chars[i][j] == "X") {
            // check all directions
            // print("row: \(i+1), col: \(j+1)")
            if (downVertical(chars: chars, i: i, j: j)) { xmasSum += 1 }
            if (upVertical(chars: chars, i: i, j: j)) { xmasSum += 1 }
            if (rightHorizontal(chars: chars, i: i, j: j)) { xmasSum += 1 }
            if (leftHorizontal(chars: chars, i: i, j: j)) { xmasSum += 1 }
            if (upRight(chars: chars, i: i, j: j)) { xmasSum += 1 }
            if (upLeft(chars: chars, i: i, j: j)) { xmasSum += 1 }
            if (downRight(chars: chars, i: i, j: j)) { xmasSum += 1 }
            if (downLeft(chars: chars, i: i, j: j)) { xmasSum += 1 }
        }

        if (chars[i][j] == "A") {
            if(xMas(chars: chars, row: i, col: j)) { masSum += 1}
        }
    }
}

print("xmas sum: \(xmasSum)")
print("x-mas sum: \(masSum)")
