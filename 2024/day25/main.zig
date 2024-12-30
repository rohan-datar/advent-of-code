const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const input = @embedFile("input");
const Vec5 = @Vector(5, u8);

fn parseSchematic(lines: [][]const u8, keys: *ArrayList(Vec5), locks: *ArrayList(Vec5)) !void {
    // for (lines) |line| {
    //     print("{s}\n", .{line});
    // }
    var startline = lines[0];
    var skip: usize = 0;
    if (mem.eql(u8, startline, "")) {
        startline = lines[1];
        skip = 1;
    }
    if (mem.eql(u8, startline, "#####")) {
        var lock = Vec5{ 0, 0, 0, 0, 0 };
        for (lines, 0..) |line, idx| {
            if (idx == skip) continue;
            for (line, 0..) |char, i| {
                if (char == '#') {
                    lock[i] += 1;
                }
            }
        }
        try locks.append(lock);
        return;
    } else if (mem.eql(u8, startline, ".....")) {
        skip += 6;
        var key = Vec5{ 0, 0, 0, 0, 0 };
        for (lines, 0..) |line, idx| {
            if (idx == skip) continue;
            for (line, 0..) |char, i| {
                if (char == '#') {
                    key[i] += 1;
                }
            }
        }
        try keys.append(key);
        return;
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var in_iterator = mem.splitScalar(u8, input, '\n');
    var lines = try ArrayList([]const u8).initCapacity(allocator, 7);
    var locks = ArrayList(Vec5).init(allocator);
    var keys = ArrayList(Vec5).init(allocator);
    while (in_iterator.next()) |current_line| {
        if (mem.eql(u8, current_line, "")) {
            // print("{s}\n", .{lines.items});
            try parseSchematic(lines.items, &keys, &locks);
            lines.clearRetainingCapacity();
        }

        try lines.append(current_line);
    }
    // print("{any}\n", .{locks.items});
    // print("{any}\n", .{keys.items});

    var sum: u64 = 0;
    for (locks.items) |lock| {
        for (keys.items) |key| {
            // print("lock: {any}, key: {any}\n", .{ lock, key });
            const fit = lock + key;
            // print("sum: {any}\n", .{fit});
            if (@reduce(.And, (fit <= Vec5{ 5, 5, 5, 5, 5 }))) {
                sum += 1;
            }
        }
    }

    print("p1: {d}\n", .{sum});
}
