const std = @import("std");
const readLib = @import("../../lib/zig/read.zig");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const PriorityQueue = std.PriorityQueue;
const File = std.fs.File;
const Allocator = std.mem.Allocator;

const Vec2 = struct {
    x: u64,
    y: u64,
};
const ClawMachine = struct {
    A: Vec2,
    B: Vec2,
    Prize: Vec2,
};

const Path = struct {
    a: u64,
    b: u64,
};

const Node = struct {
    loc: Vec2,
    cost: u8,
};

fn compareNode(context: Node, a: Node, b: Node) std.math.Order {
    _ = context;
    return std.math.order(a.cost, b.cost);
}

fn dijkstraClawMachine(machine: ClawMachine, allocator: Allocator) ?Path {
    var queue = PriorityQueue(Node, Node, compareNode).init(allocator, Node);
    defer queue.deinit();

    var visited = std.AutoHashMap(Vec2, void).init(allocator);
    defer visited.deinit();

    try queue.add(Node{ .loc = Vec2{ .x = 0, .y = 0 }, .cost = 0 });

    var a: u64 = 0;
    var b: u64 = 0;
    while (queue.peek()) {
        const current = queue.remove();
        if (current.cost == 1) {
            b += 1;
        } else if (current.cost == 3) {
            a += 1;
        }
        if ((current.loc.x == machine.Prize.x) and (current.loc.y == machine.Prize.y)) {
            return Path{ .a = a, .b = b };
        }

        queue.add(Node{ .loc = Vec2{ .x = current.x + machine.A.x, .y = current.y + machine.A.y }, .cost = 3 });
        queue.add(Node{ .loc = Vec2{ .x = current.x + machine.B.x, .y = current.y + machine.B.y }, .cost = 1 });
    }

    return null;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var input = try readLib.openFile("input", File.OpenMode.read_only);
    const contents = try input.readToEndAlloc(allocator, 999999);
    const lines = readLib.readLines(contents, allocator);
}
