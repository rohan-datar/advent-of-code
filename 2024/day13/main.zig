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
const Mat2 = struct {
    a: f64,
    b: f64,
    c: f64,
    d: f64,

    pub fn inverse(self: *Mat2) Mat2 {
        const det: f64 = (self.a * self.d) - (self.b * self.c);
        // print("det: {d}\n", .{det});
        return Mat2{ .a = self.d / det, .b = -self.b / det, .c = -self.c / det, .d = self.a / det };
    }

    pub fn preMulitplyVec2(self: *Mat2, vec: Vec2) Vec2 {
        const vfx = @as(f64, @floatFromInt(vec.x));
        const vfy = @as(f64, @floatFromInt(vec.y));
        const res_xf = (self.a * vfx) + (self.b * vfy);
        // print("calc A: {d}\n", .{res_xf});
        var res_x: i64 = 0;
        if (isWholeNum(res_xf) and (res_xf > 0)) {
            res_x = @as(i64, @intFromFloat(res_xf));
        }
        const res_yf = (self.c * vfx) + (self.d * vfy);
        // print("calc B: {d}\n", .{res_yf});
        var res_y: i64 = 0;
        if (isWholeNum(res_yf) and (res_yf > 0)) {
            res_y = @as(i64, @intFromFloat(res_yf));
        }
        return Vec2{ .x = res_x, .y = res_y };
    }
};

fn isWholeNum(num: f64) bool {
    var num_copy = num;
    const int_num = @as(i64, @intFromFloat(num_copy));
    num_copy = @as(f64, @floatFromInt(int_num));
    const diff = num - num_copy;
    // print("diff: {d}\n", .{diff});
    return (diff < 0.0000001);
}

const ClawMachine = struct {
    A: Vec2,
    B: Vec2,
    Prize: Vec2,

    pub fn cost(self: *ClawMachine) i64 {
        var mat = Mat2{ .a = @floatFromInt(self.A.x), .b = @floatFromInt(self.B.x), .c = @floatFromInt(self.A.y), .d = @floatFromInt(self.B.y) };
        // print("mat:\n {d} {d}\n {d} {d}\n", .{ mat.a, mat.b, mat.c, mat.d });
        var inv = mat.inverse();
        // print("inv:\n {d} {d}\n {d} {d}\n", .{ inv.a, inv.b, inv.c, inv.d });
        const final = inv.preMulitplyVec2(self.Prize);
        // print("final: A: {d}, B: {d}\n", .{ final.x, final.y });
        const total_cost = final.x * 3 + final.y;

        const x_sol = (final.x * self.A.x) + (final.y * self.B.x);
        const y_sol = (final.x * self.A.y) + (final.y * self.B.y);
        if (final.x != 0) {
            if ((x_sol != self.Prize.x) or (y_sol != self.Prize.y)) {
                print("solutions is wrong!\n", .{});
                print("got x: (({d}*{d} + ({d}*{d}) = {d}), wanted: {d}\n", .{ final.x, self.A.x, final.y, self.B.x, x_sol, self.Prize.x });
                print("got y: (({d}*{d} + ({d}*{d}) = {d}), wanted: {d}\n", .{ final.x, self.A.y, final.y, self.B.y, y_sol, self.Prize.y });
            }
        }
        return total_cost;
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
    for (machines.items) |machine| {
        var mach = machine;
        // print("machine: {any}\n", .{mach});
        // print("cost: {d}\n", .{mach.cost()});
        sum += mach.cost();
    }

    print("{d}\n", .{sum});
}
