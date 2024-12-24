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

enum Op {
    case and, or, xor
}

struct Gate: Equatable {
    var inA: String
    var inB: String
    var out: String
    var op: Op

    init(a: String, b: String, out: String,  op: Op) {
        self.inA = a
        self.inB = b
        self.out = out
        self.op = op
    }

    func val(aVal: Int, bVal: Int) -> Int {
        switch self.op {
        case .and:
            return aVal & bVal
        case .or:
            return aVal | bVal
        case .xor:
            return aVal ^ bVal
        }
    }
    static func == (lhs: Gate, rhs: Gate) -> Bool {
        return (lhs.inA == rhs.inA &&
                lhs.inB == rhs.inB &&
                lhs.op == rhs.op &&
                lhs.out == rhs.out)
    }

    func isInputGate() -> Bool {
        return ((self.inA.starts(with: "x")) && (self.inB.starts(with: "y")) ||
                (self.inA.starts(with: "y")) && (self.inB.starts(with: "x")))
    }

    func isOutputGate() -> Bool {
        return self.out.starts(with: "z")
    }
}

func initWire(line: String, wires: inout Dictionary<String, Int>) {
    let wireStr = line.split(separator: ": ").map({ String($0) })
    let val = Int(wireStr[1])!
    wires[wireStr[0]] = val
}

func parseGate(line: String) -> Gate {
    let gateStr = line.split(separator: " ").map({ String($0) })
    let a = gateStr[0]
    let b = gateStr[2]
    let opStr = gateStr[1]
    let out = gateStr[4]
    if (opStr == "AND") {
        return Gate(a: a, b: b, out: out, op: Op.and)
    } else if (opStr == "OR") {
        return Gate(a: a, b: b, out: out, op: Op.or)
    } else {
        return Gate(a: a, b: b, out: out, op: Op.xor)
    }

}

func fillWires(gates: [Gate], wires: inout Dictionary<String, Int>) {
    var toSolve = gates
    while !toSolve.isEmpty {
        let gate = toSolve.removeFirst()
        if let a =  wires[gate.inA] {
            if let b = wires[gate.inB] {
                let val = gate.val(aVal: a, bVal: b)
                wires[gate.out] = val
                continue
            }
        }
        toSolve.append(gate)
    }
}

func outNum (wires: Dictionary<String, Int>) -> Int {
    var num = 0
    var bitPos = 0
    var keys = [String] (wires.keys)
    keys.sort()
    for key in keys {
        if (key.starts(with: "z")) {
            let val = wires[key]!
            let nextNum = val << bitPos
            num |= nextNum
            bitPos += 1
        }
    }
    return num
}

/*
 * A full adder (x +y) + c_in = z + c_out has the following structure, c is a carry:
 * x XOR y -> k
 * c_in XOR k -> z
 * x AND y -> l
 * c_in AND k -> m
 * l OR m -> c_out
 */

let numBits = 45


func findBadWires(gates: [Gate]) -> [String] {
    var bad: [String] = []
    for gate in gates {
        switch gate.op {
        case Op.xor:
            // x XOR y -> k
            if gate.isInputGate() {
                // check for k AND c_in
                if !(gates.contains(where: { ($0.op == Op.and) && ($0.inA == gate.out || $0.inB == gate.out) }) || gates.contains(where: { ($0.op == Op.xor) && ($0.inA == gate.out || $0.inB == gate.out) })) {
                    if (Int(gate.out.suffix(2)) == 0) { continue }
                    print(gate)
                    bad.append(gate.out)
                }
            } else {
                // c_in XOR k -> z
                if !gate.isOutputGate() {
                    print(gate)
                    bad.append(gate.out)
                }
            }
        case Op.and:
            if gate.isInputGate() && Int(gate.inA.suffix(2)) == 0 { continue }
            // output is either l or m so there must be an OR gate with it as input
            if !gates.contains(where: { ($0.op == Op.or) && ($0.inA == gate.out || $0.inB == gate.out)  }) {
                print(gate)
                bad.append(gate.out)
            }
        case Op.or:
            // output has to be a carry
            if gate.isOutputGate() {
                if !(String(gate.out.suffix(2)) == String(numBits)) {
                    print(gate)
                    bad.append(gate.out)
                }
            }
        }


    }
    return bad
}


guard let lines = readLines(fromFilePath: "input") else {
    print("couldn't read file")
    exit(1)
}

var i = 0
var wires: Dictionary<String, Int> = [:]
for line in lines {
    let wireStr = line.split(separator: ": ").map({ String($0) })
    if wireStr.count != 2 {
        break
    }
    let val = Int(wireStr[1])!
    wires[wireStr[0]] = val
    i += 1
}


var gates: [Gate] = []
for j in i..<lines.count {
    let gate = parseGate(line: lines[j])
    gates.append(gate)
}

fillWires(gates: gates, wires: &wires)
print(outNum(wires: wires))

let bad = findBadWires(gates: gates)

print(bad.sorted().joined(separator: ","))
