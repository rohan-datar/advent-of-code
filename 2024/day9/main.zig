const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const input = @embedFile("input");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const filesystem = try createFilesystem(allocator);
    // print("{d}\n", .{filesystem.items});
    // print("{d}\n", .{filesystem.items.len});
    defer filesystem.deinit();
    const compact = try compactFilesystem(filesystem, allocator);
    // print("{d}\n", .{compact.items});
    print("{d}\n", .{compact.items.len});
    defer compact.deinit();
    const sum = calculateChecksum(compact);

    print("{d}\n", .{sum});
}

fn createFilesystem(allocator: Allocator) !ArrayList(i64) {
    var file = true;
    var filesystem = ArrayList(i64).init(allocator);
    var id: i64 = 0;
    for (input) |len| {
        if (len == '\n') break;
        const size = try parseInt(usize, &[_]u8{len}, 10);
        if (file) {
            try filesystem.appendNTimes(id, size);
            id += 1;
            file = false;
        } else {
            // use -1 to symbolize free space
            try filesystem.appendNTimes(-1, size);
            file = true;
        }
    }

    return filesystem;
}

fn compactFilesystem(filesystem: ArrayList(i64), allocator: Allocator) !ArrayList(i64) {
    var compact = ArrayList(i64).init(allocator);
    var i: usize = 0;
    var j: usize = filesystem.items.len - 1;
    // print("{d}\n", .{filesystem.items});
    // print("{d}\n", .{filesystem.items.len});
    outer: while (i < j) {
        // scan forward until we find an empty space
        while (filesystem.items[i] != -1) {
            try compact.append(filesystem.items[i]);
            if (i >= j) break :outer;
            i += 1;
        }

        // scan backward until we find a file
        while (filesystem.items[j] == -1) {
            if (i >= j) break :outer;
            j -= 1;
        }

        if (i >= j) break :outer;

        // print("i: {d}, j: {d}\n", .{ i, j });
        // move the item at j to i and advance
        try compact.append(filesystem.items[j]);
        i += 1;
        j -= 1;
    }
    print("i: {d}, j: {d}\n", .{ i, j });

    return compact;
}

fn calculateChecksum(filesystem: ArrayList(i64)) u64 {
    var sum: u64 = 0;
    for (filesystem.items, 0..) |id, idx| {
        const index: u64 = @intCast(idx);
        const val: u64 = @intCast(id);
        // print("pos: {d}, id: {d}\n", .{ idx, val });
        sum += val * index;
    }
    return sum;
}
