const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const concat = std.mem.concat;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.StringArrayHashMap;

fn initWire(line: []const u8, wires: *HashMap(u8)) !void {
    var it = std.mem.splitSequence(u8, line, ": ");
    const wire = it.first();
    const val_str = it.rest();
    const val = try parseInt(u8, val_str, 10);
    try wires.put(wire, val);
}

const Op = enum { and_gate, or_gate, xor_gate };

const Gate = struct {
    input_a: []const u8,
    input_b: []const u8,
    out: []const u8,
    op: Op,

    fn val(self: *Gate, a_val: u8, b_val: u8) u8 {
        switch (self.op) {
            .and_gate => {
                return a_val & b_val;
            },
            .or_gate => {
                return a_val | b_val;
            },
            .xor_gate => {
                return a_val ^ b_val;
            },
        }
    }
};

fn parseGate(line: []const u8) Gate {
    var it = std.mem.splitScalar(u8, line, ' ');
    const a = it.first();
    const op_str = it.next().?;
    const b = it.next().?;
    _ = it.next().?;
    const out = it.rest();
    var op: Op = undefined;
    if (std.mem.eql(u8, op_str, "AND")) {
        op = Op.and_gate;
    }
    if (std.mem.eql(u8, op_str, "OR")) {
        op = Op.or_gate;
    }
    if (std.mem.eql(u8, op_str, "XOR")) {
        op = Op.xor_gate;
    }
    // print("{s} {any} {s} -> {s}\n", .{ a, op, b, out });

    return Gate{ .input_a = a, .input_b = b, .out = out, .op = op };
}

fn fillWires(gates: *ArrayList(Gate), wires: *HashMap(u8)) !void {
    var toSolve = try gates.clone();
    while (toSolve.items.len != 0) {
        // print("{d}\n", .{toSolve.items.len});
        for (toSolve.items, 0..) |*gate, i| {
            // print("{s} {any} {s} -> {s}\n", .{ gate.input_a, gate.op, gate.input_b, gate.out });
            if (wires.get(gate.input_a)) |a| {
                if (wires.get(gate.input_b)) |b| {
                    const val = gate.val(a, b);
                    try wires.put(gate.out, val);
                    _ = toSolve.orderedRemove(i);
                }
            }
        }
    }
}

fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}

fn outputNum(wires: *HashMap(u8), allocator: Allocator) !u64 {
    var num: []u8 = undefined;
    const keys = wires.keys();
    std.mem.sort([]const u8, keys, {}, lessThan);
    for (keys) |key| {
        if (key[0] == 'z') {
            const val = wires.get(key).?;
            if (val == 0) {
                num = try concat(allocator, u8, &[_][]const u8{ "0", num });
            } else {
                num = try concat(allocator, u8, &[_][]const u8{ "1", num });
            }
        }
    }

    const outNum = try parseInt(u64, num, 2);
    return outNum;
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
    var wires = HashMap(u8).init(allocator);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.eql(u8, line, "")) break; // if we see an empty line, we've reached the end of initial inputs
        try initWire(line, &wires);
    }

    var gates = std.ArrayList(Gate).init(allocator);
    gates.clearAndFree();
    print("*********CONNECTIONS GOING INTO LIST*********\n\n", .{});
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // print("{s}\n", .{line});
        const gate = parseGate(line);
        // print("{s} {any} {s} -> {s}\n", .{ gate.input_a, gate.op, gate.input_b, gate.out });
        try gates.appendNTimes(gate, 1);
        print("{any}\n", .{@TypeOf(gate)});
    }

    // print("{any}\n", .{gates.items});
    // print("{any}\n", .{gates});

    print("\n**************CONNECTIONS AFTER ADDING TO LIST************\n\n", .{});
    for (gates.allocatedSlice()) |gate| {
        print("{s} {any} {s} -> {s}\n", .{ gate.input_a, gate.op, gate.input_b, gate.out });
        // print("{s}\n", .{gate});
    }
    // try fillWires(&gates, &wires);
    // const output = try outputNum(&wires, allocator);
    // print("{d}\n", .{output});
}
