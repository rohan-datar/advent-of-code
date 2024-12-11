const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const ArrayList = std.ArrayList;
const NumList = ArrayList(u64);
const Allocator = std.mem.Allocator;
const input = @embedFile("input");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var stones = try getInitialState(allocator);
    for (0..75) |_| {
        stones = try blink(stones, allocator);
        // print("{d}\n", .{stones.items});
    }

    print("{d}\n", .{stones.items.len});
}

fn getInitialState(allocator: Allocator) !NumList {
    var stones = NumList.init(allocator);
    var it = std.mem.splitSequence(u8, input, " ");
    while (it.peek() != null) {
        var stone_str = it.next().?;
        if (stone_str[stone_str.len - 1] == '\n') {
            stone_str = stone_str[0 .. stone_str.len - 1];
        }
        const stone = try parseInt(u64, stone_str, 10);
        try stones.append(stone);
    }

    return stones;
}

fn blink(stones: NumList, allocator: Allocator) !NumList {
    // deinitialize the old array once we're done with it
    defer stones.deinit();
    var newStones = NumList.init(allocator);
    for (stones.items) |stone| {
        // print("stone: {d}\n", .{stone});
        if (stone == 0) {
            try newStones.append(1);
            continue;
        }

        if ((countDigits(stone) % 2) == 0) {
            const newNums = try splitNum(stone, allocator);
            // print("newNums: {d}\n", .{newNums});
            try newStones.appendSlice(newNums);
            continue;
        }

        try newStones.append(stone * 2024);
    }

    // print("new: {d}\n", .{newStones.items});
    return newStones;
}

fn countDigits(num: u64) u64 {
    if (num == 0) {
        return 1;
    }

    var n = num;
    var digits: u64 = 0;
    while (n != 0) {
        n /= 10;
        digits += 1;
    }

    return digits;
}

fn splitNum(num: u64, allocator: Allocator) ![]u64 {
    // print("num: {d}\n", .{num});
    const digits = countDigits(num) / 2;
    var n = num;
    var second: u64 = 0;
    for (0..digits) |x| {
        second += ((n % 10) * std.math.pow(u64, 10, x));
        n /= 10;
        // print("second: {d}, n: {d}\n", .{ second, n });
    }

    const new = [_]u64{ n, second };
    const newNums = try allocator.dupe(u64, &new);
    return newNums;
}
