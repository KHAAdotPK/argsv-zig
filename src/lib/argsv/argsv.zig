// src/argsv.zig
// Q@khaa.pk

const std = @import("std");
const Arguments = @import("arguments.zig").Arguments;
const LinkedList = @import("linkedlist.zig").LinkedList;
const Parser = @import("parser.zig").Parser;

const Arg = enum {
    index,
    argc,
};

pub const Argsv = struct {
    ll: LinkedList,
    argc: usize, // Same as C/C++ argc. It is total number of argument count.

    const Self = @This();

    //pub fn add(self: *Self) !void {
    //    try self.ll.add(1, 0, 0, 1);
    //    try self.ll.add(19, 0, 0, 1);
    //}

    pub fn build(self: *Self, commands: []const u8) error {OutOfMemory, InvalidCmdLine} !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const gpaAllocator = gpa.allocator();
        defer _ = gpa.deinit();
        //var argsToGetArgc = try std.process.argsWithAllocator(gpaAllocator);
        //defer argsToGetArgc.deinit();
        if (std.process.argsWithAllocator(gpaAllocator)) |argsToGetArgc| {
            //defer argsToGetArgc.deinit();
            var argsToGetArgcCopy = argsToGetArgc;
            defer argsToGetArgcCopy.deinit();
            while (argsToGetArgcCopy.next()) |_| {
                self.argc = self.argc + 1;
            }
        } else |err| switch (err) {
            error.OutOfMemory => return error.OutOfMemory,

            // The compile error occurs because std.process.argsWithAllocator only returns error{OutOfMemory} in its error set.
            // The code is trying to handle and return error.InvalidCmdLine from it, which the compiler identifies as an invalid member of that specific error set.
            //error.InvalidCmdLine => return error.InvalidCmdLine,
        }

        //while (argsToGetArgc.next()) |_| {
        //    self.argc = self.argc + 1;
        //}

        // Mother fucker old habits,
        if (!(self.getArgc() > 1)) {
            return;
        }

        while (std.process.argsWithAllocator(gpaAllocator)) |value| {
            var args = value;
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
                            self.ll.add(i, l, t, self.getArgc() - i) catch |err| switch (err) {
                                //error.OutOfMemory => return error.OutOfMemory,
                                //error.InvalidCmdLine => return error.InvalidCmdLine,
                                LinkedList.InitError.OutOfMemory => return error.OutOfMemory,
                                LinkedList.InitError.InvalidCmdLine => return error.InvalidCmdLine,
                                LinkedList.InitError.OverFlow => return error.OutOfMemory,
                            };
                        }
                    }
                }

                // Index into args
                i = i + 1;
            }
            break;
        } else |err| switch (err) {
            error.OutOfMemory => return error.OutOfMemory,
            // The compile error occurs because std.process.argsWithAllocator only returns error{OutOfMemory} in its error set.
            // The code is trying to handle and return error.InvalidCmdLine from it, which the compiler identifies as an invalid member of that specific error set.
            //error.InvalidCmdLine => return error.InvalidCmdLine,
        }
    }

    pub fn find(self: *Self, commands: []const u8, command: []const u8) Self {
        var parser = Parser{
            .currentLineNumber = 0,
            .currentTokenNumber = 0,
        };

        if (parser.getLength(commands) == 0 or parser.getLength(command) == 0 or self.ll.size() == 0) {
            return Argsv{ .ll = LinkedList{ .arguments = null, .allocator = null, .length = 0, .currentLinkNumber = 0, .currentOptionNumber = 0, .currentCommonOptionNumber = 1 }, .argc = 0 };
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

                    if (self.ll.find(l)) |node| {
                        var local: *Arguments = node;
                        while (true) {
                            length = length + 1;

                            if (local.next == null) {
                                break;
                            }

                            local = local.next.?;
                        }
                        return Argsv{ .ll = LinkedList{ .arguments = node, .allocator = null, .length = length, .currentLinkNumber = 0, .currentOptionNumber = 0, .currentCommonOptionNumber = 1 }, .argc = 0 };
                    } else |err| switch (err) {
                        LinkedList.InitError.OutOfMemory => {
                            return Argsv{ .ll = LinkedList{ .arguments = null, .allocator = null, .length = 0, .currentLinkNumber = 0, .currentOptionNumber = 0, .currentCommonOptionNumber = 1 }, .argc = 0 };
                        },
                        LinkedList.InitError.InvalidCmdLine => {
                            return Argsv{ .ll = LinkedList{ .arguments = null, .allocator = null, .length = 0, .currentLinkNumber = 0, .currentOptionNumber = 0, .currentCommonOptionNumber = 1 }, .argc = 0 };
                        },
                        LinkedList.InitError.OverFlow => {
                            return Argsv{ .ll = LinkedList{ .arguments = null, .allocator = null, .length = 0, .currentLinkNumber = 0, .currentOptionNumber = 0, .currentCommonOptionNumber = 1 }, .argc = 0 };
                        },
                    }

                    // Working old starts here....
                    //const node: *Arguments = try self.ll.find(l);
                    //var local: *Arguments = node;
                    //while (true) {
                    //    length = length + 1;

                    //    if (local.next == null) {
                    //        break;
                    //    }

                    //    local = local.next.?;
                    //}

                    //return Argsv{ .ll = LinkedList{ .arguments = node, .allocator = null, .length = length, .currentLinkNumber = 0 }, .argc = 0 };
                    // Working old ends here
                }
            }
        }

        return Argsv{ .ll = LinkedList{ .arguments = null, .allocator = null, .length = 0, .currentLinkNumber = 0, .currentOptionNumber = 0, .currentCommonOptionNumber = 1 }, .argc = 0 };
    }

    pub fn getArgIndex(self: *Self) usize {
        var arg: Arguments = self.ll.getLink(self.ll.getCurrentLnkNumber());
        return arg.getIndex();
    }

    pub fn getArgc(self: *Self) usize {
        return self.argc;
    }

    pub fn getCommonArgc(self: *Self) usize {
        //if (self.ll.size() > 0) {
        //    var argument: Arguments = self.ll.getLink(1);
        //    return argument.getIndex();
        //} else {
        //    return self.getArgc();
        //}

        return self.ll.getCommonArgc();
    }

    pub fn getCommonOption(self: *Self) LinkedList.InitError![]const u8 {
        const message = self.ll.getCommonOption() catch |err| switch (err) {
            LinkedList.InitError.OutOfMemory => LinkedList.InitError.OutOfMemory,
            LinkedList.InitError.OverFlow => LinkedList.InitError.OverFlow,
            LinkedList.InitError.InvalidCmdLine => LinkedList.InitError.InvalidCmdLine,
        };

        //std.debug.print("{s}\n", .{message});

        return message;
    }

    pub fn getLength(self: *Self) usize {
        return self.ll.size();
    }

    pub fn getArgArgc(self: *Self) usize {
        return self.ll.getArgArgc();
    }

    pub fn getArgOption(self: *Self, l: usize, o: usize) LinkedList.InitError![]const u8 {
        return self.ll.getArgOption(l, o);
    }

    pub fn getArgOptions(self: *Self) void {
        var argument: Arguments = self.ll.getLink(self.ll.getCurrentLnkNumber());
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const gpaAllocator = gpa.allocator();
        // Executes the given code, or block, on scope exit. "Scope exit" includes reaching the end of the scope or returning from the scope.
        defer _ = gpa.deinit();

        if (std.process.argsWithAllocator(gpaAllocator)) |argsToGetArgc| {
            var argsToGetArgcCopy = argsToGetArgc;
            defer argsToGetArgcCopy.deinit();

            var dummyGPA = std.heap.GeneralPurposeAllocator(.{}){};
            const dummyGPAllocator = dummyGPA.allocator();
            defer _ = dummyGPA.deinit();

            //var argArray = try std.ArrayList.init([]const u8).okOrOutError();
            var outerArray: [][]*u8 = &.{};
            //outerArray[0] = gpaAllocator.alloc(u8, 10);

            if (dummyGPAllocator.alloc(*u8, 10)) |ptr| {
                outerArray[0] = ptr;
            } else |err| {
                switch (err) {
                    error.OutOfMemory => return,
                }
            }

            //if (std.ArrayList.init([]const u8)) |_| {} else |err| switch (err) {}

            var i: usize = 0;
            var j: usize = 0;
            var flag: bool = false;
            while (argsToGetArgcCopy.next()) |arg| {
                // I want to put each arg in the array of U8, how...

                if (flag == true) {
                    j = j + 1;
                    if (j < argument.getArgc()) {
                        std.debug.print(" {s} ", .{arg});
                    } else {
                        j = 0;
                        flag = false;

                        std.debug.print("\n", .{});
                    }
                }

                if (argument.getIndex() == i) {
                    std.debug.print("Found {} -> {s} and n = {} -> ", .{ argument.getIndex(), arg, argument.getArgc() });

                    flag = true;
                }

                i = i + 1;
            }
        } else |err| switch (err) {
            error.OutOfMemory => return,
            error.InvalidCmdLine => return,
        }
    }

    pub fn new(allocator: ?*std.mem.Allocator) Self {
        //pub fn new() !Self {
        //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        //defer arena.deinit();
        //const allocator = arena.allocator();

        if (allocator.?.create(Arguments)) |node| {
            node.* = Arguments{ .i = 0, .l = 0, .t = 0, .n = 0, .next = null, .prev = null };
            return Argsv{ .ll = LinkedList{ .arguments = node, .allocator = allocator, .length = 0, .currentLinkNumber = 0, .currentOptionNumber = 0, .currentCommonOptionNumber = 1 }, .argc = 0 };
        } else |err| switch (err) {
            error.OutOfMemory => {
                return Argsv{ .ll = LinkedList{ .arguments = null, .allocator = null, .length = 0, .currentLinkNumber = 0, .currentOptionNumber = 0, .currentCommonOptionNumber = 1 }, .argc = 0 };
            },
        }

        //const node: *Arguments = try allocator.?.create(Arguments);
        //node.* = Arguments{ .i = 0, .l = 0, .t = 0, .n = 0, .next = null, .prev = null };
        //return Argsv{ .ll = LinkedList{ .arguments = node, .allocator = allocator, .length = 0, .currentLinkNumber = 0 }, .argc = 0 };
    }
    
    pub fn help(self: *Self, commands: []const u8) []const u8 {
        var parser = Parser {
            .currentLineNumber = 0,
            .currentTokenNumber = 0,
        };
         
        var current: *Arguments = self.ll.arguments orelse return ""; 

        const l = current.getLine();

        std.debug.print("Line = {}\n", .{l});

        const line = parser.getLineByNumber(commands, l);

        const helpText = parser.getHelpText(line);

        return helpText;
    }

    pub fn index(self: *Self) usize {

        var current: *Arguments = self.ll.arguments orelse return 0;

        const i = current.getIndex();

        return i;
    }

    // Argument count
    pub fn n(self: *Self) usize {
     
        var current: *Arguments = self.ll.arguments orelse return 0;

        const m = current.getArgc();

        return m;        
    }

    pub fn next(self: *Self) bool {
        return self.ll.next();
    }

    pub fn nextOption(self: *Self) bool {
        return self.ll.nextOption();
    }

    pub fn nextCommonOption(self: *Self) bool {
        return self.ll.nextCommonOption();
    }

    pub fn traverse(self: *Self) void {
        self.ll.traverse();
    }    
};
