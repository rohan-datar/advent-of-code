const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const ArrayList = std.ArrayList;
const HashMap = std.AutoArrayHashMap;
const NumList = HashMap(u64, u64);
const Allocator = std.mem.Allocator;
const input = @embedFile("input");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var stones = NumList.init(allocator);
    try getInitialState(&stones);
    for (0..75) |_| {
        stones = try blink(stones, allocator);
        // print("{d}\n", .{stones.keys()});
    }

    var sum: u64 = 0;
    for (stones.values()) |value| {
        sum += value;
    }

    print("{d}\n", .{sum});
}

fn getInitialState(stones: *NumList) !void {
    var it = std.mem.splitSequence(u8, input, " ");
    while (it.peek() != null) {
        var stone_str = it.next().?;
        if (stone_str[stone_str.len - 1] == '\n') {
            stone_str = stone_str[0 .. stone_str.len - 1];
        }
        const stone = try parseInt(u64, stone_str, 10);
        try stones.put(stone, 1);
    }
}

fn blink(stones: NumList, allocator: Allocator) !NumList {
    var newStones = NumList.init(allocator);
    var it = stones.iterator();
    while (it.next()) |entry| {
        const stone = entry.key_ptr.*;
        const count = entry.value_ptr.*;
        if (stone == 0) {
            const val = newStones.get(1);
            if (val) |one| {
                try newStones.put(1, one + count);
            } else {
                try newStones.put(1, count);
            }
            continue;
        }

        if ((countDigits(stone) % 2) == 0) {
            const newNums = try splitNum(stone, allocator);
            const val1 = newStones.get(newNums[0]);
            if (val1) |first| {
                try newStones.put(newNums[0], first + count);
            } else {
                try newStones.put(newNums[0], count);
            }
            const val2 = newStones.get(newNums[1]);
            if (val2) |second| {
                try newStones.put(newNums[1], second + count);
            } else {
                try newStones.put(newNums[1], count);
            }
            continue;
        }

        const val = newStones.get(stone * 2024);
        if (val) |num| {
            try newStones.put(stone * 2024, num + count);
        } else {
            try newStones.put(stone * 2024, count);
        }
    }

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
