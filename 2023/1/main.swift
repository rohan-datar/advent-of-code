import Foundation

// Wasteful to make this every function call, so we'll use that in global space.
let digits = ["0":"zero", "1":"one", "2":"two", "3":"three", "4": "four", "5": "five", "6": "six", "7": "seven", "8":"eight", "9": "nine"]

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


func lineVal(_ line: String) -> Int {
    var firstDigit: String? = nil
    var lastDigit: String? = nil

    var i: Int = 0
    print(line)
    // print(line.count)
    while i < line.count {
        print(i)
        let idx = line.index(line.startIndex, offsetBy: i)
        if line[idx].isNumber {
            if firstDigit == nil {
                firstDigit = String(line[idx])
            }

            lastDigit = String(line[idx])
            i += 1
            continue
        }

        for (digit, word) in digits {
            if i + word.count > line.count {
                continue
            }
            let wordEndIdx = line.index(idx, offsetBy: word.count - 1)
            let wordNum = line[idx...wordEndIdx]
            print("digit: \(digit),  \(word)")
            print("wordNum: \(wordNum)")
            if wordNum == word {
                if firstDigit == nil {
                    firstDigit = digit
                }

                lastDigit = digit
                i += (word.count)
                print(i)
                continue
            }
        }

        i += 1
    }

    guard let firstDigit = firstDigit else {
        return -1
    }

    guard let lastDigit = lastDigit else {
        return -1
    }

    let lineNumStr = firstDigit + lastDigit
    return Int(lineNumStr) ?? -1
}


guard let lines = readLines(fromFilePath: "input") else {
    print("couldn't read file")
    exit(1)
}

// print(lines)

var sum = 0
for line in lines {
    sum += lineVal(line)
}

print(sum)
