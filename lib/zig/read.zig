const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const File = std.fs.File;

pub fn openFile(path: []const u8, mode: File.OpenMode) !File {
    // 4096 is the maximum file path length in linux, macos is smaller, and I don't care about windows
    var path_buffer: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&path_buffer);
    const allocator = fba.allocator();
    // get the absolute path of the file
    const abs_path = try std.fs.realpathAlloc(allocator, path);
    defer allocator.free(path);

    const file = try std.fs.openFileAbsolute(abs_path, File.OpenFlags{ .mode = mode });

    return file;
}

pub fn readLines(contents: []u8, allocator: Allocator) ![][]u8 {
    var it = std.mem.splitScalar(u8, contents, '\n');
    var lines = ArrayList([]u8).init(allocator);
    while (it.peek()) {
        try lines.append(it.next().?);
    }

    return lines.items;
}
