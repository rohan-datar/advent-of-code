const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;

pub fn main() !void {
    // read in file
    var input_file = try std.fs.cwd().openFile("input", .{});
    defer input_file.close();

    var buf_reader = std.io.bufferedReader(input_file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var sum: u32 = 0;

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    const alloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const allocator = arena.allocator();

    var rule_map = HashMap(u8, ArrayList(u8)).init(allocator);
    defer rule_map.deinit();

    // read in the rules
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.eql(u8, line, "")) break; // if we see an empty line, we've reached the end of the rules
        try parseRule(line, &rule_map, allocator);
    }

    // read in the updates
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.eql(u8, line, "")) continue; // skip the empty demlimiter
        const updates = try parseUpdateLine(line, allocator);
        const valid = try checkRules(rule_map, updates, allocator);
        if (valid) continue;

        // print("mid: {d}\n", .{middleVal(updates)});
        const fixed = try fixUnordered(rule_map, updates, allocator);
        // print("fixed: {d}\n", .{fixed.items});
        sum += middleVal(fixed);

        updates.deinit();
        fixed.deinit();
    }

    print("{d}\n", .{sum});
}

fn parseRule(rule_line: []const u8, rule_map: *HashMap(u8, ArrayList(u8)), allocator: std.mem.Allocator) !void {
    var it = std.mem.splitSequence(u8, rule_line, "|");
    const key_str = it.first();
    const after_str = it.rest();

    // print("key: {s}, val: {s}\n", .{ key_str, after_str });
    const key = try parseInt(u8, key_str, 10);
    const after_val = try parseInt(u8, after_str, 10);

    var value = rule_map.get(key);
    if (value) |*after| {
        // print("key: {d}, rules: {d}\n", .{ key, after.items });
        try after.*.append(after_val);
        // print("after appending rules: {d}\n", .{after.items});
        try rule_map.put(key, after.*);
    } else {
        var after_list = ArrayList(u8).init(allocator);
        try after_list.append(after_val);
        try rule_map.put(key, after_list);
    }
}

fn parseUpdateLine(line: []const u8, allocator: std.mem.Allocator) !ArrayList(u8) {
    var it = std.mem.splitSequence(u8, line, ",");

    var updates = ArrayList(u8).init(allocator);
    while (it.peek() != null) {
        const next_str = it.next().?;
        const next = try parseInt(u8, next_str, 10);

        try updates.append(next);
    }

    return updates;
}

fn contains(comptime T: type, list: ArrayList(T), val: T) bool {
    for (list.items) |item| {
        if (item == val) {
            return true;
        }
    }

    return false;
}

fn checkRules(rule_map: HashMap(u8, ArrayList(u8)), updates: ArrayList(u8), allocator: std.mem.Allocator) !bool {
    // print("checking: {d}", .{updates.items});
    var seen = ArrayList(u8).init(allocator);
    defer seen.deinit();
    for (updates.items) |page_num| {
        try seen.append(page_num);
        // print("current: {d}, seen: {d}\n", .{ page_num, seen.items });
        const rule_list = rule_map.get(page_num);
        // if we have rules for this page
        if (rule_list) |rules| {
            // print("rules: {d}\n", .{rules.items});
            // check each rule to see if it was already seen.
            for (rules.items) |rule| {
                if (contains(u8, seen, rule)) return false;
            }
        } else {
            continue;
        }
    }

    return true;
}

fn fixUnordered(rule_map: HashMap(u8, ArrayList(u8)), updates: ArrayList(u8), allocator: std.mem.Allocator) !ArrayList(u8) {
    var fixed = ArrayList(u8).init(allocator);
    updateLoop: for (updates.items) |update| {
        // print("fixed: {d}, update: {d}\n", .{ fixed.items, update });
        if (fixed.items.len == 0) {
            try fixed.append(update);
            continue;
        }
        const rule_list = rule_map.get(update);
        if (rule_list) |rules| {
            // print("rules: {d}\n", .{rules.items});
            // iterate through the fixed list and enter the item before the first elemnent that it has to be before
            for (fixed.items, 0..) |item, i| {
                if (contains(u8, rules, item)) {
                    try fixed.insert(i, update);
                    continue :updateLoop;
                }
            }
            // if we don't find any rule violations, append the element at the end
            try fixed.append(update);
        } else {
            // if we don't have any rules append the update
            try fixed.append(update);
        }
    }
    return fixed;
}

fn middleVal(list: ArrayList(u8)) u8 {
    const mid = @divFloor(list.items.len, 2);
    return list.items[mid];
}
