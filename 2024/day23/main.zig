const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const concat = std.mem.concat;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.StringArrayHashMap;

fn addConnection(line: []const u8, network: *HashMap(*ArrayList([]const u8)), allocator: Allocator) !void {
    var it = std.mem.splitScalar(u8, line, '-');
    const a = it.first();
    const b = it.rest();
    print("a: {s}, b: {s}\n", .{ a, b });
    if (network.get(a)) |connections| {
        print("{any}\n", .{connections});
        try connections.append(b);
    } else {
        var conn = ArrayList([]const u8).init(allocator);
        try conn.append(b);
        try network.put(a, &conn);
    }

    if (network.get(b)) |connections| {
        try connections.append(a);
    } else {
        var conn = ArrayList([]const u8).init(allocator);
        try conn.append(a);
        try network.put(b, &conn);
    }
}

fn possibleHistorians(network: *HashMap(*ArrayList([]const u8))) !u64 {
    var h: u64 = 0;
    for (network.keys()) |key| {
        if (!(key[0] == 't')) {
            continue;
        }

        const connections = network.get(key).?;
        if (connections.items.len == 2) {
            h += 1;
        }
    }
    return h;
}
pub fn main() !void {
    var input_file = try std.fs.cwd().openFile("input", .{});
    defer input_file.close();

    var buf_reader = std.io.bufferedReader(input_file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    // var sum: u32 = 0;

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    const alloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const allocator = arena.allocator();
    var network = HashMap(*ArrayList([]const u8)).init(allocator);
    defer network.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try addConnection(line, &network, allocator);
    }

    const hist = try possibleHistorians(&network);
    print("{d}\n", .{hist});
}
