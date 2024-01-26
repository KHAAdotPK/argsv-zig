// src/argsv.zig
// Q@khaa.pk

const std = @import("std");
const Arguments = @import("arguments.zig").Arguments;
const LinkedList = @import("linkedlist.zig").LinkedList;
const Parser = @import("parser.zig").Parser;

pub const Argsv = struct {
    ll: LinkedList,
    argc: usize, // Same as C/C++ argc. It is total number of argument count.

    const Self = @This();

    //pub fn add(self: *Self) !void {
    //    try self.ll.add(1, 0, 0, 1);
    //    try self.ll.add(19, 0, 0, 1);
    //}

    pub fn build(self: *Self, commands: []const u8) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const gpaAllocator = gpa.allocator();
        defer _ = gpa.deinit();
        var argsToGetArgc = try std.process.argsWithAllocator(gpaAllocator);
        defer argsToGetArgc.deinit();

        while (argsToGetArgc.next()) |_| {
            self.argc = self.argc + 1;
        }

        // Mother fucker old habits,
        if (!(self.getArgc() > 1)) {
            return;
        }

        var args = try std.process.argsWithAllocator(gpaAllocator);
        defer args.deinit();

        var parser = Parser{
            .currentLineNumber = 0,
            .currentTokenNumber = 0,
        };

        var i: usize = 0;
        while (args.next()) |arg| {
            const nLines = parser.getTotalNumberOfLines(commands);

            // l has line number
            for (1..(nLines + 1)) |l| {
                const line = parser.getLineByNumber(commands, l);
                var t: usize = 0;
                while (true) {
                    const token = parser.goToNextToken(line);

                    if (parser.getLength(token) == 0) {
                        break;
                    }

                    // Token number
                    t = t + 1;

                    if (Parser.compareSlice(arg, token) == true) {
                        _ = try self.ll.add(i, l, t, self.getArgc() - i);
                    }
                }
            }
            // Index into args
            i = i + 1;
        }
    }

    pub fn find(self: *Self, commands: []const u8, command: []const u8) !Self {
        var parser = Parser{
            .currentLineNumber = 0,
            .currentTokenNumber = 0,
        };

        if (parser.getLength(commands) == 0 or parser.getLength(command) == 0 or self.ll.size() == 0) {
            return Argsv{ .ll = LinkedList{ .arguments = null, .allocator = null, .length = 0 }, .argc = 0 };
            //return;
        }

        var l: usize = 0;
        while (true) {
            const line = parser.goToNextLine(commands);

            if (parser.getLength(line) == 0) {
                break;
            }

            l = l + 1;

            while (true) {
                const token = parser.goToNextToken(line);

                if (parser.getLength(token) == 0) {
                    break;
                }

                if (Parser.compareSlice(command, token) == true) {
                    var length: usize = 0;
                    const node: *Arguments = try self.ll.find(l);
                    var local: *Arguments = node;
                    while (true) {
                        length = length + 1;

                        if (local.next == null) {
                            break;
                        }

                        local = local.next.?;
                    }

                    //std.debug.print(" i = {} ", .{i});
                    return Argsv{ .ll = LinkedList{ .arguments = node, .allocator = null, .length = length }, .argc = 0 };
                }
            }
        }

        return Argsv{ .ll = LinkedList{ .arguments = null, .allocator = null, .length = 0 }, .argc = 0 };
    }

    pub fn getArgc(self: *Self) usize {
        return self.argc;
    }

    pub fn getLength(self: *Self) usize {
        return self.ll.getLength();
    }

    pub fn new(allocator: ?*std.mem.Allocator) !Self {
        //pub fn new() !Self {
        //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        //defer arena.deinit();
        //const allocator = arena.allocator();

        const node: *Arguments = try allocator.?.create(Arguments);
        node.* = Arguments{ .i = 0, .l = 0, .t = 0, .n = 0, .next = null, .prev = null };
        return Argsv{ .ll = LinkedList{ .arguments = node, .allocator = allocator, .length = 0 }, .argc = 0 };
    }

    pub fn traverse(self: *Self) void {
        self.ll.traverse();
    }
};