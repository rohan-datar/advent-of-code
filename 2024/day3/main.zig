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
    var enabled: bool = true;
    outer: while (idx < input_str.len) {
        // print("idx: {d}\n", .{idx});
        if (idx + 4 > input_str.len) break :outer;

        // if we're enabled look for don't()
        if (enabled) {
            if (idx + 7 > input_str.len) break :outer;
            const don_t: []const u8 = input_str[idx .. idx + 7];
            // if we find a don't continue
            if (std.mem.eql(u8, don_t, "don't()") {
                enabled = false;
                idx += 7;
                continue :outer;
            }
        } else {
            const do: []const u8 = input_str[idx .. idx + 4];
            // if we're disabled and find a do() re-enable
            if (std.mem.eql(u8, do, "do()") {
                enabled = true;
                idx += 4;
            } else {
                idx += 1;
                continue :outer;
            }
        }

        // check if the next four letters are mul(
        const keyword: []const u8 = input_str[idx .. idx + 4];
        if (std.mem.eql(u8, keyword, "mul(")) {
            idx += 4;
            var i: usize = idx;
            // scan forward until we see a comma
            first: while (input_str[i] != ',') {
                const next_char = input_str[i];
                // if we see a non-numeric character break
                const digit_str = [_]u8{next_char};
                _ = parseInt(u8, &digit_str, 10) catch break :first;
                // increment
                i += 1;
            }

            // if we broke because the sequence was invalid move on
            if (input_str[i] != ',') {
                idx = i;
                continue :outer;
            }

            const first_num = try parseInt(u32, input_str[idx..i], 10);
            // print("first: {d}\n", .{first_num});

            // now scan until we see a ')'
            i += 1;
            idx = i;
            second: while (input_str[i] != ')') {
                const next_char = input_str[i];
                // if we see a non-numeric character break
                const digit_str = [_]u8{next_char};
                _ = parseInt(u8, &digit_str, 10) catch break :second;
                // increment
                i += 1;
            }

            // if we broke because the sequence was invalid move on
            if (input_str[i] != ')') {
                idx = i;
                continue :outer;
            }

            const second_num = try parseInt(u32, input_str[idx..i], 10);

            // print("first: {d}, second: {d}\n", .{first_num, second_num});
            try buf.append(Mul{ .a = first_num, .b = second_num });
        }
        idx += 1;
    }
}
