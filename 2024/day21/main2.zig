const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const concat = std.mem.concat;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const input = @embedFile("input");
const HashMap = std.StringArrayHashMap;
const Vec2 = @Vector(2, i8);

fn numKeypad(pad: *HashMap(Vec2)) !void {
    try pad.put("A", Vec2{ 0, 0 });
    try pad.put("0", Vec2{ 0, 1 });
    try pad.put("1", Vec2{ 1, 2 });
    try pad.put("2", Vec2{ 1, 1 });
    try pad.put("3", Vec2{ 1, 0 });
    try pad.put("4", Vec2{ 2, 2 });
    try pad.put("5", Vec2{ 2, 1 });
    try pad.put("6", Vec2{ 2, 0 });
    try pad.put("7", Vec2{ 3, 2 });
    try pad.put("8", Vec2{ 3, 1 });
    try pad.put("9", Vec2{ 3, 0 });
}

fn dirKeypad(pad: *HashMap(Vec2)) !void {
    try pad.put("A", Vec2{ 1, 0 });
    try pad.put("^", Vec2{ 1, 1 });
    try pad.put("<", Vec2{ 0, 2 });
    try pad.put(">", Vec2{ 0, 0 });
    try pad.put("v", Vec2{ 0, 1 });
}

fn bestDirPaths(paths: *HashMap([]const u8)) !void {
    try paths.put("AA", "A");
    try paths.put("^^", "A");
    try paths.put(">>", "A");
    try paths.put("vv", "A");
    try paths.put("<<", "A");
    try paths.put("A^", "<A");
    try paths.put("^A", ">A");
    try paths.put("A>", "vA");
    try paths.put(">A", "^A");
    try paths.put("v^", "^A");
    try paths.put("^v", "vA");
    try paths.put("v<", "<A");
    try paths.put("<v", ">A");
    try paths.put("v>", ">A");
    try paths.put(">v", "<A");

    try paths.put("Av", "v<A");
    try paths.put("vA", ">^A");
    try paths.put("A<", "v<<A");
    try paths.put("<A", ">>^A");

    try paths.put("><", "<<A");
    try paths.put("<>", ">>A");
    try paths.put("<^", ">^A");
    try paths.put("^<", "v<A");
    try paths.put(">^", "<^A");
    try paths.put("^>", "v>A");
}

fn isValidPos(keypad: HashMap(Vec2), pos: Vec2) bool {
    const positions = keypad.values();
    for (positions) |position| {
        if (@reduce(.And, (pos == position))) {
            return true;
        }
    }
    return false;
}

const Path = struct {
    position: Vec2,
    path: []u8,
};

const pathError = error{noPath};

fn cmp(context: void, a: Path, b: Path) std.math.Order {
    _ = context;
    return std.math.order(a.path.len, b.path.len);
}
fn calculatePaths(keyPad: HashMap(Vec2), current: []const u8, next: []const u8, allocator: Allocator) ![]Path {
    var queue = std.PriorityQueue(Path, void, cmp).init(allocator, undefined);
    defer queue.deinit();
    var visited = std.AutoArrayHashMap(Vec2, void).init(allocator);
    defer visited.deinit();
    var validPaths = ArrayList(Path).init(allocator);
    var leastMoves: usize = std.math.maxInt(usize);

    const start = keyPad.get(current).?;
    const end = keyPad.get(next).?;
    try queue.add(Path{ .position = start, .path = &[_]u8{} });

    while (queue.count() > 0) {
        const curr = queue.remove();
        if (@reduce(.And, (curr.position == end))) {
            if (curr.path.len <= leastMoves) {
                leastMoves = curr.path.len;
                try validPaths.append(curr);
            }
        }

        if (!visited.contains(curr.position)) {
            try visited.put(curr.position, {});

            const upPos = curr.position + Vec2{ 1, 0 };
            if (isValidPos(keyPad, upPos)) {
                const newPath = try concat(allocator, u8, &[_][]const u8{ curr.path, "^" });
                try queue.add(Path{ .position = upPos, .path = newPath });
            }

            const downPos = curr.position + Vec2{ -1, 0 };
            if (isValidPos(keyPad, downPos)) {
                const newPath = try concat(allocator, u8, &[_][]const u8{ curr.path, "v" });
                try queue.add(Path{ .position = downPos, .path = newPath });
            }

            const leftPos = curr.position + Vec2{ 0, 1 };
            if (isValidPos(keyPad, leftPos)) {
                const newPath = try concat(allocator, u8, &[_][]const u8{ curr.path, "<" });
                try queue.add(Path{ .position = leftPos, .path = newPath });
            }

            const rightPos = curr.position + Vec2{ 0, -1 };
            if (isValidPos(keyPad, rightPos)) {
                const newPath = try concat(allocator, u8, &[_][]const u8{ curr.path, ">" });
                try queue.add(Path{ .position = rightPos, .path = newPath });
            }
        }
    }
    // print("start: {s}, end: {s}\n", .{ current, next });
    // for (validPaths.items) |path| {
    //     // print("{s}\n", .{path.path});
    // }
    return validPaths.items;
}

fn printMap(map: HashMap([]u8)) void {
    for (map.keys()) |key| {
        const val = map.get(key).?;
        print("{s} : {s}\n", .{ key, val });
    }
}

fn getPossiblePaths(keypad: HashMap(Vec2), allocator: Allocator) !HashMap([][]u8) {
    const buttons = keypad.keys();
    // print("buttons: {c}\n", .{buttons});
    var paths = HashMap([][]u8).init(allocator);
    for (buttons) |button| {
        for (buttons) |b| {
            // print("button: {c}, b: {c}\n", .{ button, b });
            const possiblePaths = try calculatePaths(keypad, button, b, allocator);
            var strippedPaths = ArrayList([]u8).init(allocator);
            for (possiblePaths) |p| {
                try strippedPaths.append(p.path);
            }
            const seq = try concat(allocator, u8, &[_][]const u8{ button, b });
            try paths.put(seq, strippedPaths.items);
        }
    }

    return paths;
}

fn optimizePaths(padPaths: HashMap([][]u8), dirPaths: HashMap([]const u8), allocator: Allocator) !HashMap([]u8) {
    var bestPaths = HashMap([]u8).init(allocator);
    const keys = padPaths.keys();
    for (keys) |key| {
        // print("key: {s}\n", .{key});
        const paths = padPaths.get(key).?;
        if (paths.len == 1) {
            try bestPaths.put(key, paths[0]);
            continue;
        }
        var bestPathScore: usize = std.math.maxInt(usize);
        for (paths) |path| {
            var i: usize = 0;
            while (i < path.len - 1) : (i += 1) {
                const current = path[i];
                const next = path[i + 1];
                const moves = [_]u8{ current, next };
                const move = moves[0..];
                const dirP = dirPaths.get(move).?;
                if (dirP.len <= bestPathScore) {
                    bestPathScore = dirP.len;
                    // print(" path: {s}\n", .{path});
                    try bestPaths.put(key, path);
                }
            }
        }
    }
    return bestPaths;
}

fn pathLength(seq: []const u8, numPadPaths: HashMap([]u8), dirPadPaths: HashMap([]const u8), numBots: u8, allocator: Allocator) !usize {
    const digSeq = try std.mem.concat(allocator, u8, &[_][]const u8{ "A", seq });
    var numPadPath = ArrayList(u8).init(allocator);
    var i: usize = 0;
    while (i < digSeq.len - 1) : (i += 1) {
        const current = digSeq[i];
        const next = digSeq[i + 1];
        const moves = [_]u8{ current, next };
        const move = moves[0..];
        const charPath = numPadPaths.get(move).?;
        try numPadPath.appendSlice(charPath);
    }

    var dirPath = numPadPath;
    for (0..numBots - 1) |_| {
        // print("{s}\n", .{dirPath.items});
        var currentPath = try dirPath.clone();
        dirPath.clearAndFree();
        try currentPath.insert(0, 'A');
        i = 0;
        while (i < currentPath.items.len - 1) : (i += 1) {
            const current = currentPath.items[i];
            const next = currentPath.items[i + 1];
            // print("currentPath: {s}\n", .{currentPath.items});
            // print("{d}\n", .{currentPath.items.len});
            // print("i: {d}, current: {c}, next: {c}\n", .{ i, current, next });
            const moves = [_]u8{ current, next };
            const move = moves[0..];
            // print("move: {s}\n ", .{move});
            const charPath = dirPadPaths.get(move).?;
            try dirPath.appendSlice(charPath);
        }
    }

    print("{s}: {s}\n", .{ seq, dirPath.items });
    return dirPath.items.len;
}

pub fn main() !void {
    var input_file = try std.fs.cwd().openFile("test", .{});
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

    var numkeys = HashMap(Vec2).init(allocator);
    var dirkeys = HashMap(Vec2).init(allocator);
    try numKeypad(&numkeys);
    // print("nums: {c}\n", .{numkeys.keys()});
    try dirKeypad(&dirkeys);

    var dirPaths = HashMap([]const u8).init(allocator);
    try bestDirPaths(&dirPaths);
    const possibleNumPaths = try getPossiblePaths(numkeys, allocator);
    const numPaths = try optimizePaths(possibleNumPaths, dirPaths, allocator);
    // printMap(numPaths);

    // read in the rules
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const plen = try pathLength(line, numPaths, dirPaths, 4, allocator);
        print("{d}\n", .{plen});
    }
}
