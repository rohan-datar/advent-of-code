import Foundation

/// read the input file
/// and return the array of lines in the file
func readInput(fromFilePath: String) -> String? {
    let input = try? String(contentsOfFile: fromFilePath, encoding: String.Encoding.ascii)
    guard let input = input else {
        return nil
    }

    return input
}

func parseMem(mem: String) -> [(Int, Int)] {
}
