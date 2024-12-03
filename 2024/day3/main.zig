const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const input = @embedFile("test");
const ArrayList = std.ArrayList;
const gpa = std.heap.GeneralPurposeAllocator(.{}){};

const Mul = struct {
    a: u32,
    b: u32,
};

pub fn main() !void {
    // read in file

    // var sum: u32 = 0;
    // print("{d}\n", .{sum});
}

fn getMuls(input: []const u8, buf: ArrayList(Mul)) !ArrayList(Mul) {
    buf.init(gpa.allocator());

    var idx: usize = 0;
    while (idx < input.len) {
        if (idx + 3 > input.len) continue;
        // check if the next four letters are mul(
        const keyword: []const u8 = input[idx .. idx+4];
        if (std.mem.eql(u8, keyword, "mul(") {
            var i: usize = idx;
            // scan forward until we see a comma
            while(
        }
    }
}
