const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const input = @embedFile("input");

const ComputerError = error{InvalidOperand};

const Computer = struct {
    regA: u64,
    regB: u64,
    regC: u64,
    program: []u3,
    pc: usize,
    output: ArrayList(u3),

    // combo operand
    fn combo(self: *Computer, op: u3) !u64 {
        return switch (op) {
            0...3 => @intCast(op),
            4 => self.regA,
            5 => self.regB,
            6 => self.regC,
            7 => ComputerError.InvalidOperand,
        };
    }

    // division operations
    fn div(self: *Computer, op: u3) !u64 {
        const com = try self.combo(op);
        const denom = std.math.pow(u64, 2, com);
        return @divTrunc(self.regA, denom);
    }

    fn adv(self: *Computer, op: u3) !void {
        const res = try self.div(op);
        self.regA = res;
    }

    fn bdv(self: *Computer, op: u3) !void {
        const res = try self.div(op);
        self.regB = res;
    }

    fn cdv(self: *Computer, op: u3) !void {
        const res = try self.div(op);
        self.regC = res;
    }

    // xor instructions
    fn bxl(self: *Computer, op: u3) void {
        const op_lit: u64 = @intCast(op);
        self.regB = self.regB ^ op_lit;
    }

    fn bxc(self: *Computer) void {
        self.regB = self.regB ^ self.regC;
    }

    fn bst(self: *Computer, op: u3) !void {
        const com = try self.combo(op);
        const res = com % 8;
        self.regB = res;
    }

    fn jnz(self: *Computer, op: u3) usize {
        if (self.regA != 0) {
            const op_lit: usize = @intCast(op);
            return op_lit;
        } else {
            return self.pc + 2;
        }
    }

    fn out(self: *Computer, op: u3) !void {
        const com = try self.combo(op);
        const val: u3 = @truncate(com);
        try self.output.append(val);
    }

    fn run(self: *Computer) ![]u3 {
        while (self.pc < self.program.len) {
            // print("regA: {d}, regB: {d}, regC: {d}, out: {d}, program: {d}, pc: {d}\n", .{ self.regA, self.regB, self.regC, self.output.items, self.program, self.pc });
            const instr = self.program[self.pc];
            switch (instr) {
                0 => try self.adv(self.program[self.pc + 1]),
                1 => self.bxl(self.program[self.pc + 1]),
                2 => try self.bst(self.program[self.pc + 1]),
                3 => {
                    self.pc = self.jnz(self.program[self.pc + 1]);
                    continue;
                },
                4 => self.bxc(),
                5 => try self.out(self.program[self.pc + 1]),
                6 => try self.bdv(self.program[self.pc + 1]),
                7 => try self.cdv(self.program[self.pc + 1]),
            }
            self.pc += 2;
        }

        return self.output.items;
    }
};

fn parseReg(line: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, line, ' ');
    _ = it.first();
    _ = it.next().?;
    const val_str = it.rest();
    const val = try parseInt(u64, val_str, 10);
    return val;
}

fn parseProgram(line: []const u8, allocator: Allocator) ![]u3 {
    var it = std.mem.splitScalar(u8, line, ' ');
    _ = it.first();
    const instructions = it.rest();
    var instr_it = std.mem.splitScalar(u8, instructions, ',');
    var ins = ArrayList(u3).init(allocator);
    // defer ins.deinit();
    while (instr_it.next()) |op_str| {
        const op = try parseInt(u3, op_str, 10);
        try ins.append(op);
    }
    return ins.items;
}
pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    const alloc = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const allocator = arena.allocator();
    var in_iterator = std.mem.splitScalar(u8, input, '\n');
    const rega_str = in_iterator.next().?;
    const regA = try parseReg(rega_str);
    const regb_str = in_iterator.next().?;
    const regB = try parseReg(regb_str);
    const regc_str = in_iterator.next().?;
    const regC = try parseReg(regc_str);
    _ = in_iterator.next().?;
    const program_str = in_iterator.next().?;
    const ops = try parseProgram(program_str, allocator);

    var computer = Computer{ .regA = regA, .regB = regB, .regC = regC, .program = ops, .pc = 0, .output = ArrayList(u3).init(allocator) };

    const out = try computer.run();
    print("part 1: {d}\n", .{out});

    var newA: u64 = 0;
    while (true) {
        print("{d}\n", .{newA});
        computer.regA = newA;
        computer.pc = 0;
        const newOut = try computer.run();
        print("ops: {d}\n", .{ops});
        print("out: {d}\n", .{newOut});
        if (std.mem.eql(u3, ops, newOut)) {
            print("part 2: {d}\n", .{newA});
            break;
        }
        newA += 1;
    }
}
