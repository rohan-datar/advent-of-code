const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;
const HashMap = std.AutoArrayHashMap;
const Vec2 = @Vector(2, u64);

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

fn gpsCoordinate(self: Vec2) u64 {
    return (100 * self[0]) + self[1];
}

const Map = struct {
    wallPositions: HashMap(Vec2, void),
    boxPositions: HashMap(Vec2, void),
    botPosition: Vec2,

    fn parseMapLine(self: *Map, line: []const u8, x: u64) !void {
        for (line, 0..) |char, idx| {
            const index: u64 = @intCast(idx);
            if (char == '#') {
                try self.wallPositions.put(Vec2{ x, index }, {});
            }

            if (char == 'O') {
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
        return self.boxPositions.contains(pos);
    }

    fn isFree(self: *Map, pos: Vec2) bool {
        return (!self.isWall(pos) and !self.isBox(pos));
    }

    fn printMap(self: *Map) void {
        var x: u64 = 0;
        var y: u64 = 0;
        while (x < 8) : (x += 1) {
            while (y < 8) : (y += 1) {
                const pos = Vec2{ x, y };
                if (self.isWall(pos)) {
                    print("#", .{});
                    continue;
                }

                if (self.isBox(pos)) {
                    print("O", .{});
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

    fn moveChain(self: *Map, free: Vec2, dir: Direction) !void {
        // print("bot: {any}, free: {any}\n", .{ self.botPosition, free });
        const nxt: Vec2 = next(self.botPosition, dir);
        self.botPosition = nxt;
        if (self.isBox(nxt)) {
            _ = self.boxPositions.swapRemove(nxt);
            try self.boxPositions.put(free, {});
        }
        // self.printMap();
    }

    pub fn moveBot(self: *Map, direction: u8) !void {
        const dir = try charToDir(direction);

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
                try self.moveChain(nxt, dir);
                return;
            }

            nxt = next(nxt, dir);
        }
    }

    fn totalCoordinates(self: *Map) u64 {
        const keys = self.boxPositions.keys();
        var total: u64 = 0;
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

    var map: Map = Map{ .wallPositions = HashMap(Vec2, void).init(allocator), .boxPositions = HashMap(Vec2, void).init(allocator), .botPosition = Vec2{ 0, 0 } };
    var x: u64 = 0;
    // read in the map
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.eql(u8, line, "")) break; // if we see an empty line, we've reached the end of the map
        try map.parseMapLine(line, x);
        x += 1;
    }

    // print("boxes:\n", .{});
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

    // print("bot end: {any}\n", .{map.botPosition});

    print("{d}\n", .{map.totalCoordinates()});
}
