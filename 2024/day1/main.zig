const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

fn readInput(input: []const u8) [][]const u8 {
    // read in file
    var input_file = try std.fs.cwd().openFile("input", .{});
    defer input_file.close();

    var buf_reader = std.io.bufferedReader(input_file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {}
}

pub fn main() !void {}
