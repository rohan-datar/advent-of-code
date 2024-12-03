const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const input = @embedFile("test");
const ArrayList = std.ArrayList;

const Mul = struct {
    a: u32,
    b: u32,
};

pub fn main() !void {
    // read in file

    var sum: u32 = 0;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var muls = ArrayList(Mul).init(allocator);
    defer muls.deinit();

    try getMuls(input, &muls);

    for (muls.items) |mul| {
        const val = mul.a * mul.b;
        sum += val;
    }

    print("{d}\n", .{sum});
}

fn getMuls(input_str: []const u8, buf: *ArrayList(Mul)) !void {
    var idx: usize = 0;
    while (idx < input_str.len) {
        if (idx + 3 > input_str.len) break;

        // check if the next four letters are mul(
        const keyword: []const u8 = input_str[idx .. idx + 4];
        if (std.mem.eql(u8, keyword, "mul(")) {
            idx += 4;
            var i: usize = idx;
            // scan forward until we see a comma
            while (input_str[i] != ',') {
                const next_char = input_str[i];
                // if we see a non-numeric character break
                const digit_str = [_]u8{next_char};
                _ = parseInt(u8, &digit_str, 10) catch break;
                // increment
                i += 1;
            }

            // if we broke because the sequence was invalid move on
            if (input_str[i] != ',') {
                idx += i;
                continue;
            }

            const first_num = try parseInt(u32, input_str[idx..i], 10);

            // now scan until we see a ')'
            i += 1;
            idx += i;
            while (input_str[i] != ')') {
                const next_char = input_str[i];
                // if we see a non-numeric character break
                const digit_str = [_]u8{next_char};
                _ = parseInt(u8, &digit_str, 10) catch break;
                // increment
                i += 1;
            }

            // if we broke because the sequence was invalid move on
            if (input_str[i] != ')') {
                idx += i;
                continue;
            }

            const second_num = try parseInt(u32, input_str[idx..i], 10);

            try buf.append(Mul{ .a = first_num, .b = second_num });
        }
        idx += 1;
    }
}
