const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.AutoArrayHashMap;
const Vec2 = @Vector(2, i64);

const NoDirection = error{CouldNotMatchDirection};
const Direction = enum {
    up,
    down,
    left,
    right,
};

fn charToDir(char: u8) !Direction {
    return switch (char) {
        '^' => Direction.up,
        'v' => Direction.down,
        '<' => Direction.left,
        '>' => Direction.right,
        else => NoDirection.CouldNotMatchDirection,
    };
}

fn next(self: Vec2, dir: Direction) Vec2 {
    return switch (dir) {
        Direction.up => Vec2{ self[0] - 1, self[1] },
        Direction.down => Vec2{ self[0] + 1, self[1] },
        Direction.left => Vec2{ self[0], self[1] - 1 },
        Direction.right => Vec2{ self[0], self[1] + 1 },
    };
}

fn gpsCoordinate(self: Vec2) i64 {
    return (100 * self[0]) + self[1];
}

fn transformMapLine(line: []const u8, allocator: Allocator) ![]u8 {
    var newLine = ArrayList(u8).init(allocator);
    for (line) |char| {
        if (char == '#') {
            try newLine.append('#');
            try newLine.append('#');
            continue;
        }

        if (char == 'O') {
            try newLine.append('[');
            try newLine.append(']');
            continue;
        }

        if (char == '@') {
            try newLine.append('@');
            try newLine.append('.');
            continue;
        }

        try newLine.append('.');
        try newLine.append('.');
    }

    return newLine.items;
}

const Map = struct {
    wallPositions: HashMap(Vec2, void),
    boxPositions: HashMap(Vec2, void), // the key will be the left side of the box and the value will be the right
    botPosition: Vec2,
    allocator: Allocator,

    fn parseMapLine(self: *Map, line: []const u8, x: i64) !void {
        const newLine = try transformMapLine(line, self.allocator);
        for (newLine, 0..) |char, idx| {
            const index: i64 = @intCast(idx);
            if (char == '#') {
                try self.wallPositions.put(Vec2{ x, index }, {});
            }

            if (char == '[') {
                try self.boxPositions.put(Vec2{ x, index }, {});
            }

            if (char == '@') {
                self.botPosition = Vec2{ x, index };
            }
        }
    }

    fn isWall(self: *Map, pos: Vec2) bool {
        return self.wallPositions.contains(pos);
    }

    fn isBox(self: *Map, pos: Vec2) bool {
        return self.boxPositions.contains(pos) or self.boxPositions.contains(Vec2{ pos[0], pos[1] - 1 });
    }

    fn isBoxRight(self: *Map, pos: Vec2) bool {
        return !self.boxPositions.contains(pos) and self.boxPositions.contains(Vec2{ pos[0], pos[1] - 1 });
    }

    fn isFree(self: *Map, pos: Vec2) bool {
        return (!self.isWall(pos) and !self.isBox(pos));
    }

    fn printMap(self: *Map) void {
        var x: i64 = 0;
        var y: i64 = 0;
        while (x < 51) : (x += 1) {
            while (y < 101) : (y += 1) {
                const pos = Vec2{ x, y };
                if (self.isWall(pos)) {
                    print("#", .{});
                    continue;
                }

                if (self.boxPositions.contains(pos)) {
                    print("[", .{});
                    continue;
                }

                if (self.boxPositions.contains(Vec2{ pos[0], pos[1] - 1 })) {
                    print("]", .{});
                    continue;
                }

                if (std.meta.eql(self.botPosition, pos)) {
                    print("@", .{});
                    continue;
                }

                print(".", .{});
            }
            y = 0;
            print("\n", .{});
        }
    }

    fn boxOtherSide(self: *Map, pos: Vec2) Vec2 {
        if (self.isBoxRight(pos)) {
            return Vec2{ pos[0], pos[1] - 1 };
        } else {
            return Vec2{ pos[0], pos[1] + 1 };
        }
    }

    fn canMoveVert(self: *Map, current: Vec2, dir: Direction, seen: *HashMap(Vec2, void)) !bool {
        if (!self.isBox(current)) {
            const nextPos = next(current, dir);
            if (self.isFree(nextPos)) {
                return true;
            } else if (self.isWall(nextPos)) {
                return false;
            } else {
                return try self.canMoveVert(nextPos, dir, seen);
            }
        } else {
            const nextPos = next(current, dir);
            const otherNextPos = next(self.boxOtherSide(current), dir);

            // add this box to the seen list
            if (self.isBoxRight(current)) {
                try seen.*.put(Vec2{ current[0], current[1] - 1 }, {});
            } else {
                try seen.*.put(current, {});
            }

            if (self.isWall(nextPos) or self.isWall(otherNextPos)) {
                return false;
            } else if (self.isFree(nextPos) and self.isFree(otherNextPos)) {
                return true;
            } else {
                return try self.canMoveVert(nextPos, dir, seen) and try self.canMoveVert(otherNextPos, dir, seen);
            }
        }
    }

    fn moveChainHor(self: *Map, free: Vec2, dir: Direction) !void {
        // print("bot: {any}, free: {any}\n", .{ self.botPosition, free });
        var nxt: Vec2 = next(self.botPosition, dir);
        self.botPosition = nxt;
        var visited = ArrayList(Vec2).init(self.allocator);
        defer visited.deinit();
        while (!std.meta.eql(nxt, free)) {
            if (self.boxPositions.contains(nxt)) {
                try visited.append(nxt);
            }
            nxt = next(nxt, dir);
        }

        // loop to move all the boxes we saw
        for (visited.items) |box| {
            _ = self.boxPositions.swapRemove(box);
            try self.boxPositions.put(next(box, dir), {});
        }
    }

    pub fn moveBot(self: *Map, direction: u8) !void {
        const dir = try charToDir(direction);

        if (dir == Direction.left or dir == Direction.right) {
            var nxt = next(self.botPosition, dir);
            while (true) {
                // print("nxt: {any}\n", .{nxt});
                // if we see a wall in the direction we're moving, this is a no-op
                if (self.isWall(nxt)) {
                    return;
                }

                // if we see a free space we can move
                if (self.isFree(nxt)) {
                    // print("found free space at : {any}\n", .{nxt});
                    // move the chain of boxes we've got so far and the bot of course
                    try self.moveChainHor(nxt, dir);
                    // self.printMap();
                    return;
                }

                nxt = next(nxt, dir);
            }
        } else {
            var seen = HashMap(Vec2, void).init(self.allocator);
            defer seen.deinit();
            const movable = try self.canMoveVert(self.botPosition, dir, &seen);
            if (movable) {
                self.botPosition = next(self.botPosition, dir);
                const boxes = seen.keys();
                for (boxes) |box| {
                    _ = self.boxPositions.swapRemove(box);
                }

                for (boxes) |box| {
                    try self.boxPositions.put(next(box, dir), {});
                }
            }
        }
        // self.printMap();
    }

    fn totalCoordinates(self: *Map) i64 {
        const keys = self.boxPositions.keys();
        var total: i64 = 0;
        for (keys) |key| {
            // print("box: {any}\n", .{key});
            total += gpsCoordinate(key);
        }

        return total;
    }
};

pub fn main() !void {
    // read in file
    var input_file = try std.fs.cwd().openFile("input", .{});
    defer input_file.close();

    var buf_reader = std.io.bufferedReader(input_file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    const alloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const allocator = arena.allocator();

    var map: Map = Map{
        .wallPositions = HashMap(Vec2, void).init(allocator),
        .boxPositions = HashMap(Vec2, void).init(allocator),
        .botPosition = Vec2{ 0, 0 },
        .allocator = allocator,
    };
    var x: i64 = 0;
    // read in the map
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.eql(u8, line, "")) break; // if we see an empty line, we've reached the end of the map
        try map.parseMapLine(line, x);
        x += 1;
    }

    // map.printMap();

    // for (map.boxPositions.keys()) |key| {
    //     print("{any}\n", .{key});
    // }

    // read in the updates
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line) |dir| {
            // print("{c}\n", .{dir});
            try map.moveBot(dir);
            // print("bot: {any}\n", .{map.botPosition});
            // print("boxes:\n", .{});
            // for (map.boxPositions.keys()) |key| {
            //     print("{any}\n", .{key});
            // }
        }
    }

    map.printMap();

    // print("bot end: {any}\n", .{map.botPosition});

    print("{d}\n", .{map.totalCoordinates()});
}
