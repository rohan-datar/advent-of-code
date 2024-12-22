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

let p = 16777216

func iterSec(_ num: Int) -> Int {
    var n = num
    n = (n ^ (n * 64)) % p
    n = (n ^ (n / 32)) % p
    n = (n ^ (n * 2048)) % p
    return n
}


guard let lines = readLines(fromFilePath: "input") else {
    print("couldn't read file")
    exit(1)
}

// struct Seq: Hashable {
//     var seq: (Int, Int, Int, Int)

//     init(seq: (Int, Int, Int, Int)) {
//         self.seq = seq
//     }
//     static func == (lhs: Seq, rhs: Seq) -> Bool {
//         return lhs.seq == rhs.seq
//     }

//     func hash(into hasher: inout Hasher) {
//         hasher.combine(seq)
//     }
// }

var sum = 0
var seqValues: Dictionary<SIMD4<Int>, Int> = [:]
for line in lines {
    var costs: [Int] = []
    var num = Int(line) ?? -1
    if num == -1 {
        exit(1)
    }
    for _ in 0..<2000 {
        num = iterSec(num)
        costs.append(num % 10)
    }
    sum += num

    var deltas: [Int] = []
    for i in 1..<costs.count {
        deltas.append(costs[i] - costs[i-1])
    }

    var seenSequences: Set<SIMD4<Int>> = []
    for j in 0..<deltas.count - 3 {
        let seq = SIMD4<Int>(deltas[j], deltas[j+1], deltas[j+2], deltas[j+3])
        if !seenSequences.contains(seq) {
            let cost = costs[j+4]
            seqValues[seq, default: 0] += cost
            seenSequences.insert(seq)
        }
    }
}

print("p1: \(sum)")

let max = seqValues.values.max() ?? -1
print("p2: \(max)")
