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
    defer filesystem.deinit();
    const compact = try compactFilesystem(filesystem, allocator);
    const sum = calculateChecksum(compact);
    print("{d}\n", .{sum});
    const compact2 = try compactFilesystemNoFrag(filesystem, allocator);
    const sum2 = calculateChecksum(compact2);
    print("{d}\n", .{sum2});
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

fn compactFilesystem(filesystem: ArrayList(i64), allocator: Allocator) ![]i64 {
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

        if (i >= j) break :outer;

        // print("i: {d}, j: {d}\n", .{ i, j });
        // move the item at j to i and advance
        try compact.append(filesystem.items[j]);
        i += 1;
        j -= 1;
    }
    // print("i: {d}, j: {d}\n", .{ i, j });

    return compact.items;
}

const fileBlock = struct {
    start: usize,
    size: usize,
};

fn findAllEmpty(filesystem: []i64, allocator: Allocator) ![]fileBlock {
    var blocks = ArrayList(fileBlock).init(allocator);
    var i: usize = 0;
    while (i < filesystem.len) {
        if (filesystem[i] == -1) {
            const start = i;
            var size: usize = 0;
            while (filesystem[i] == -1) {
                i += 1;
                size += 1;
                if (i >= filesystem.len) break;
            }

            try blocks.append(fileBlock{ .start = start, .size = size });
        } else {
            i += 1;
        }
    }
    return blocks.items;
}

fn findFiles(filesystem: []i64, allocator: Allocator) ![]fileBlock {
    var blocks = ArrayList(fileBlock).init(allocator);
    var i: usize = 0;
    while (i < filesystem.len) {
        if (filesystem[i] != -1) {
            const start = i;
            var size: usize = 0;
            while (filesystem[i] == filesystem[start]) {
                i += 1;
                size += 1;
                if (i >= filesystem.len) break;
            }

            try blocks.append(fileBlock{ .start = start, .size = size });
        } else {
            i += 1;
        }
    }
    return blocks.items;
}

fn compactFilesystemNoFrag(filesystem: ArrayList(i64), allocator: Allocator) ![]i64 {
    var compact = filesystem.items;
    // print("pre: {d}\n", .{compact});
    const files = try findFiles(compact, allocator);
    // print("files: {any}\n", .{files});
    var j: usize = files.len;
    while (j > 0) {
        j -= 1;
        const empty = try findAllEmpty(compact, allocator);
        for (empty) |block| {
            if (block.start > files[j].start) continue;
            if (files[j].size <= block.size) {
                // move the file over
                var i: usize = 0;
                while (i < files[j].size) {
                    compact[block.start + i] = compact[files[j].start + i];
                    compact[files[j].start + i] = -1;
                    i += 1;
                }
            }
        }
        // print("{d}\n", .{compact});
    }

    return compact;
}

fn calculateChecksum(filesystem: []i64) u64 {
    var sum: u64 = 0;
    for (filesystem, 0..) |id, idx| {
        if (id == -1) continue;
        const index: u64 = @intCast(idx);
        const val: u64 = @intCast(id);
        // print("pos: {d}, id: {d}\n", .{ idx, val });
        sum += val * index;
    }
    return sum;
}
