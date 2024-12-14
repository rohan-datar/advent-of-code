const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const input = @embedFile("input");

const Vec2 = struct {
    x: i64,
    y: i64,
};

const ClawMachine = struct {
    A: Vec2,
    B: Vec2,
    Prize: Vec2,

    pub fn cost(self: *ClawMachine) i64 {
        // for a system A*(x_a, y_a) + B*(x_b, y_b) = (x_p, y_p)
        // b = ((x_p*y_a) - (y_p*x_a))/((x_b*y_a) - (y_b*x_a))
        // and
        // a = (x_p - (b*x_b))/x_a
        // convert all values to floats for the calculation

        const b_numerator = (self.Prize.x * self.A.y) - (self.Prize.y * self.A.x);
        const b_denominator = (self.B.x * self.A.y) - (self.B.y * self.A.x);
        // check that b is an integer
        if (@mod(b_numerator, b_denominator) != 0) {
            return 0;
        }
        const b = @divTrunc(b_numerator, b_denominator);

        const a_numerator = self.Prize.x - (b * self.B.x);
        if (@mod(a_numerator, self.A.x) != 0) {
            return 0;
        }
        const a = @divTrunc(a_numerator, self.A.x);

        return (a * 3) + b;
    }
};

fn parseMachine(lines: [][]const u8) !ClawMachine {
    var a: Vec2 = undefined;
    var b: Vec2 = undefined;
    var prize: Vec2 = undefined;

    for (lines) |line| {
        // print("{s}\n", .{line});
        var it = mem.splitScalar(u8, line, ' ');
        var x: i64 = 0;
        var y: i64 = 0;
        if (mem.eql(u8, it.peek().?, "Button")) {
            _ = it.first();
            const button = it.next().?;
            // print("button: {s}\n", .{button});
            var x_str = it.next().?;
            // print("x: {s}\n", .{x_str});
            x_str = mem.trimRight(u8, x_str, ",");
            const y_str = it.next().?;
            // print("y: {s}\n", .{y_str});

            var x_it = mem.splitScalar(u8, x_str, '+');
            _ = x_it.first();
            const x_val = x_it.rest();
            x = try parseInt(i64, x_val, 10);

            var y_it = mem.splitScalar(u8, y_str, '+');
            _ = y_it.first();
            const y_val = y_it.rest();
            y = try parseInt(i64, y_val, 10);

            if (mem.eql(u8, button, "A:")) {
                a = Vec2{ .x = x, .y = y };
                continue;
            }
            if (mem.eql(u8, button, "B:")) {
                b = Vec2{ .x = x, .y = y };
                continue;
            }
        }

        if (mem.eql(u8, it.first(), "Prize:")) {
            var x_str = it.next().?;
            x_str = mem.trimRight(u8, x_str, ",");
            const y_str = it.next().?;

            var x_it = mem.splitScalar(u8, x_str, '=');
            _ = x_it.first();
            const x_val = x_it.rest();
            x = try parseInt(i64, x_val, 10);

            var y_it = mem.splitScalar(u8, y_str, '=');
            _ = y_it.first();
            const y_val = y_it.rest();
            y = try parseInt(i64, y_val, 10);

            prize = Vec2{ .x = x, .y = y };
        }
    }

    return ClawMachine{ .A = a, .B = b, .Prize = prize };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var in_iterator = mem.splitScalar(u8, input, '\n');
    var lines = try ArrayList([]const u8).initCapacity(allocator, 3);
    var machines = ArrayList(ClawMachine).init(allocator);
    while (in_iterator.next()) |current_line| {
        if (mem.eql(u8, current_line, "")) {
            const machine = try parseMachine(lines.items);
            try machines.append(machine);
            lines.clearRetainingCapacity();
        }

        try lines.append(current_line);
    }

    var sum: i64 = 0;
    var sum2: i64 = 0;
    for (machines.items) |machine| {
        var mach = machine;
        // print("machine: {any}\n", .{mach});
        // print("cost: {d}\n", .{mach.cost()});
        sum += mach.cost();
        var mach2 = machine;
        mach2.Prize.x += 10000000000000;
        mach2.Prize.y += 10000000000000;
        sum2 += mach2.cost();
    }

    print("p1: {d}\n", .{sum});
    print("p2: {d}\n", .{sum2});
}
