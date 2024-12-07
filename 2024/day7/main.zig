const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    // read in file
    var input_file = try std.fs.cwd().openFile("test", .{});
    defer input_file.close();

    var buf_reader = std.io.bufferedReader(input_file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var sum: u64 = 0;

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    const alloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const allocator = arena.allocator();
    // read in the rules
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var eqn = try parseEqn(line, allocator);

        if (eqn.isValid()) {
            sum += eqn.result;
        }
    }
    print("{d}\n", .{sum});
}

const Op = enum { add, mul };

const Equation = struct {
    result: u64,
    components: ArrayList(u64),

    fn valid(self: *Equation, next: u64, i: u64) bool {
        if (i == self.components.items.len) {
            return next == self.result;
        }
        var nextVal: u64 = 0;
        inline for (std.meta.fields(Op)) |op| {
            if (op.value == @intFromEnum(Op.add)) {
                nextVal = next + self.components.items[i];
            } else if (op.value == @intFromEnum(Op.mul)) {
                nextVal = next * self.components.items[i];
            }
            if (self.valid(nextVal, i + 1)) return true;
        }
        return false;
    }
    fn isValid(self: *Equation) bool {
        return self.valid(self.components.items[0], 1);
    }
};

fn parseEqn(line: []const u8, allocator: Allocator) !Equation {
    var it = std.mem.splitSequence(u8, line, ":");
    const result_str = it.first();
    const components_str = it.rest();

    // parse result
    const result = try parseInt(u64, result_str, 10);

    var components = ArrayList(u64).init(allocator);
    it = std.mem.splitSequence(u8, components_str, " ");
    _ = it.first();
    // parse components
    while (it.peek() != null) {
        const component_str = it.next().?;
        const component = try parseInt(u64, component_str, 10);

        try components.append(component);
    }

    return Equation{ .result = result, .components = components };
}
