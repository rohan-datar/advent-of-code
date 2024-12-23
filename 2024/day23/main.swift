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


struct Triple: Hashable {
    var a: String
    var b: String
    var c: String

    init(a: String, b: String, c: String) {
        self.a = a
        self.b = b
        self.c = c
    }

    static func == (lhs: Triple, rhs: Triple) -> Bool {
        return (lhs.a == rhs.a &&
                lhs.b == rhs.b &&
                lhs.c == rhs.c) ||
                (lhs.a == rhs.a &&
                lhs.b == rhs.c &&
                lhs.c == rhs.b) ||
                (lhs.a == rhs.b &&
                lhs.b == rhs.a &&
                lhs.c == rhs.c) ||
                (lhs.a == rhs.b &&
                lhs.b == rhs.c &&
                lhs.c == rhs.a) ||
                (lhs.a == rhs.c &&
                lhs.b == rhs.b &&
                lhs.c == rhs.a) ||
                (lhs.a == rhs.c &&
                lhs.b == rhs.a &&
                lhs.c == rhs.b)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(a)
        hasher.combine(b)
        hasher.combine(c)
    }
}

func addConnection(line: String, network: inout Dictionary<String, [String]>, triples: inout [Triple]) {
    let comps = line.split(separator: "-").map({ String($0) })
    network[comps[0], default: []].append(comps[1])
    network[comps[1], default: []].append(comps[0])
    for link in network[comps[0], default: []] {
        guard let dst = network[comps[1]] else {
            continue
        }
        if dst.contains(link) {
            triples.append(Triple(a: link, b: comps[0], c: comps[1]))
        }
    }
}

guard let lines = readLines(fromFilePath: "input") else {
    print("couldn't read file")
    exit(1)
}

var network: Dictionary<String, [String]> = [:]
var triples: [Triple] = []
for line in lines {
    addConnection(line: line, network: &network, triples: &triples)
}

var sum = 0
for triple in triples {
    if (triple.a.starts(with: "t") || triple.b.starts(with: "t") || triple.c.starts(with: "t")) {
        sum += 1
    }
}

print(sum)
