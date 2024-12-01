const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    // read in file
    var input_file = try std.fs.cwd().openFile("input", .{});
    defer input_file.close();

    var buf_reader = std.io.bufferedReader(input_file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var sum: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_val = try parseLine(line);
        sum += line_val;
    }

    print("{d}\n", .{sum});
}

const Number = struct {
    word: []const u8,
    digit: u8,
};

const digits = [_]Number{
    .{ .word = "zero", .digit = '0' },
    .{ .word = "one", .digit = '1' },
    .{ .word = "two", .digit = '2' },
    .{ .word = "three", .digit = '3' },
    .{ .word = "four", .digit = '4' },
    .{ .word = "five", .digit = '5' },
    .{ .word = "six", .digit = '6' },
    .{ .word = "seven", .digit = '7' },
    .{ .word = "eight", .digit = '8' },
    .{ .word = "nine", .digit = '9' },
};

fn parseLine(line: []const u8) !u32 {
    var first_digit: ?u8 = null;
    var last_digit: ?u8 = null;

    var idx: usize = 0;
    print("line: {s}\n", .{line});
    while (idx < line.len) {
        var digit: ?u8 = null;
        for (digits) |num| {
            if (line[idx] == num.digit) {
                digit = num.digit;
                idx += 1;
                break;
            }
            if (idx + num.word.len > line.len) continue;
            const wordnum: []const u8 = line[idx .. idx + num.word.len];
            print("num: {s}\n", .{num.word});
            print("wordnum: {s}\n", .{wordnum});
            if (std.mem.eql(u8, wordnum, num.word)) {
                // print("got here\n", .{});
                digit = num.digit;
                idx += num.word.len;
                break;
            }
        }

        if (digit == null) {
            idx += 1;
            continue;
        }
        if (first_digit == null) first_digit = digit.?;
        last_digit = digit.?;
    }

    const line_key = [_]u8{ first_digit.?, last_digit.? };
    const line_key_value = try parseInt(u32, &line_key, 10);
    return line_key_value;
}

fn parseLineOrig(line: []const u8) !u32 {
    var first_digit: ?u8 = null;
    var last_digit: ?u8 = null;

    for (line) |char| {
        const digit_str = [_]u8{char};
        _ = parseInt(u8, &digit_str, 10) catch continue;
        if (first_digit == null) first_digit = char;
        last_digit = char;
    }

    const line_key = [_]u8{ first_digit.?, last_digit.? };
    const line_key_value = try parseInt(u32, &line_key, 10);
    return line_key_value;
}
