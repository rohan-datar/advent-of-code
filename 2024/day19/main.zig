const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;
const HashMap = std.StringHashMap;
const ArrayList = std.ArrayList;
const input = @embedFile("input");

fn availableTowels(list: []const u8, allocator: Allocator) !HashMap(void) {
    var it = std.mem.splitSequence(u8, list, ", ");
    var towels = HashMap(void).init(allocator);

    while (it.next()) |towel| {
        try towels.put(towel, {});
    }

    return towels;
}

fn findDesign(pattern: []const u8, avail: HashMap(void)) bool {
    if (avail.contains(pattern)) {
        return true;
    }
    var i: usize = 0;
    while (i < pattern.len) : (i += 1) {
        if (avail.contains(pattern[0..i]) and findDesign(pattern[i..], avail)) {
            return true;
        }
    }
    return false;
}

fn findDesign2(pattern: []const u8, avail: HashMap(void), seen: *HashMap(u64)) !usize {
    // print("{s}\n", .{pattern});
    if (seen.contains(pattern)) {
        const val = seen.get(pattern).?;
        if (val > 0) {
            return val;
        }
    }
    var sum: usize = 0;
    if (avail.contains(pattern)) {
        sum += 1;
    }
    var i: usize = 0;
    while (i < pattern.len) : (i += 1) {
        if (avail.contains(pattern[0..i])) {
            const perms = try findDesign2(pattern[i..], avail, seen);
            if (perms > 0) {
                sum += perms;
            }
        }
    }
    try seen.put(pattern, sum);
    return sum;
}

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    const alloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const allocator = arena.allocator();
    var in_iterator = std.mem.splitScalar(u8, input, '\n');

    const towel_list = in_iterator.first();
    var towels = try availableTowels(towel_list, allocator);
    defer towels.deinit();

    _ = in_iterator.next().?;

    var possible: usize = 0;
    var permutations: usize = 0;
    var seen = HashMap(u64).init(allocator);
    while (in_iterator.next()) |pattern| {
        if (findDesign(pattern, towels)) {
            possible += 1;
            permutations += try findDesign2(pattern, towels, &seen);
        }
        print("pattern: {s}\n", .{pattern});
    }

    print("possible: {d}\n", .{possible});
    print("permutations: {d}\n", .{permutations});
}
