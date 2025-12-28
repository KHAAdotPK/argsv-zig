// src/linkedlist.zig
// Q@khaa.pk

const std = @import("std");
const Arguments = @import("arguments.zig").Arguments;

pub const LinkedList = struct {
    arguments: ?*Arguments,
    allocator: ?*std.mem.Allocator,
    length: usize, // Number of links
    currentLinkNumber: usize,
    currentOptionNumber: usize,
    currentCommonOptionNumber: usize,

    pub const InitError = error{
        OutOfMemory,
        OverFlow,
        InvalidCmdLine,
    };

    pub fn add(self: *LinkedList, i: usize, l: usize, t: usize, n: usize) InitError!void {
        if (self.arguments == null) {
            return;
        }

        var current: *Arguments = self.arguments.?;

        while (true) {
            if (current.next == null) {
                break;
            }

            current = current.next.?;
        }

        if (current.prev == null and current.i == 0) {
            current.i = i;
            current.l = l;
            current.t = t;
            current.n = n;
            current.prev = null;
            current.next = null;
        } else {
            const node = try self.allocator.?.create(Arguments);
            node.* = Arguments{ .i = i, .l = l, .t = t, .n = n, .next = null, .prev = current };

            current.next = node;

            current = current.next.?;

            current.prev.?.setArgc(current.getIndex() - current.prev.?.getIndex());
        }

        self.length = self.length + 1;
    }

    pub fn find(self: *LinkedList, l: usize) InitError!*Arguments {
        var current: *Arguments = self.arguments.?;
        var node: *Arguments = try self.allocator.?.create(Arguments);
        node.* = Arguments{ .i = 0, .l = 0, .t = 0, .n = 0, .next = null, .prev = null };

        if (self.size() == 0) {
            return node;
        }

        //var current: *Arguments = self.arguments.?;
        //var node: *Arguments = try self.allocator.create(Arguments);
        //node.* = Arguments{ .i = 0, .l = 0, .t = 0, .n = 0, .next = null, .prev = null };

        while (true) {
            if (current.getLine() == l) {
                //std.debug.print(" Found \n", .{});
                if (node.*.i == 0 and node.*.l == 0 and node.*.t == 0 and node.*.prev == null and node.*.next == null) {
                    node.* = Arguments{ .i = current.i, .l = current.l, .t = current.t, .n = current.n, .next = null, .prev = null };
                    //std.debug.print(" 1 Found \n", .{});
                } else {
                    //node.*.next = try self.allocator.create(Arguments);
                    node.next = try self.allocator.?.create(Arguments);
                    //node.*.next.?.* = Arguments{ .i = current.i, .l = current.l, .t = current.t, .n = current.n, .next = null, .prev = node };
                    node.next.?.* = Arguments{ .i = current.i, .l = current.l, .t = current.t, .n = current.n, .next = null, .prev = node };
                    //node = node.*.next.?;
                    node = node.next.?;
                    //std.debug.print(" 2 Found \n", .{});
                }
            }

            if (current.next == null) {
                //while (node.*.prev != null) {
                //    node = node.*.prev.?;
                //}
                while (true) {
                    //std.debug.print("In loop\n", .{});
                    if (node.prev == null) {
                        // Return node here
                        //break;
                        return node;
                    }

                    node = node.prev.?;
                }
                break;
            }

            current = current.next.?;
        }
    }

    pub fn getArgArgc(self: *LinkedList) usize {
        var argument: Arguments = self.getLink(self.getCurrentLnkNumber());

        return argument.getArgc();
    }

    pub fn getArgOption(self: *LinkedList, l: usize, o: usize) InitError![]const u8 {
        //try self.getOption(l, o) catch |err| switch (err) {};

        //if (self.getOption(l, o)) |_| {} else |err| switch (err) {
        //    InitError.InvalidCmdLine => return,
        //}

        const message = self.getOption(l, o) catch |err| switch (err) {
            InitError.OutOfMemory => return InitError.OutOfMemory,
            InitError.OverFlow => return InitError.OverFlow,
            InitError.InvalidCmdLine => return InitError.InvalidCmdLine,
        };

        //if (self.getOption(l, o)) |arg| {
        //    std.debug.print(" -> {s} ", .{arg});
        //} else |err| switch (err) {
        //    InitError.OutOfMemory => return,
        //    InitError.InvalidCmdLine => return,
        //    InitError.OverFlow => return,
        //}

        return message;
    }

    pub fn getCommonArgc(self: *LinkedList) usize {
        var argument: Arguments = self.getLink(1);

        if (argument.getIndex() == 0) {
            
            return 0;
        }
        
        return argument.getIndex() - 1;
    }

    pub fn getCommonOption(self: *LinkedList) InitError![]const u8 {
        const message = std.heap.page_allocator.dupe(u8, &[1]u8{'\n'}) catch |err| switch (err) {
            error.OutOfMemory => return InitError.OutOfMemory,
        };

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const gpaAllocator = gpa.allocator();
        // Executes the given code, or block, on scope exit. "Scope exit" includes reaching the end of the scope or returning from the scope.
        defer _ = gpa.deinit();

        if (std.process.argsAlloc(gpaAllocator)) |args| {
            defer std.process.argsFree(gpaAllocator, args);
            var i: usize = 1;
            for (args) |arg| {
                if (i == self.currentCommonOptionNumber) {
                    return try std.heap.page_allocator.dupe(u8, arg);
                }

                i = i + 1;
            }
        } else |_| {
            return InitError.OutOfMemory;
        }

        return message;
    }

    pub fn getCurrentLnkNumber(self: *LinkedList) usize {
        return self.currentLinkNumber;
    }

    pub fn getLength(self: *LinkedList) usize {
        return self.length;
    }

    pub fn getLink(self: *LinkedList, j: usize) Arguments {
        if (j > self.size()) {
            return Arguments{ .i = 0, .l = 0, .t = 0, .n = 0, .next = null, .prev = null };
        }

        var i: usize = 1;
        var current: *Arguments = self.arguments.?;
        while (true) {
            if (i == j) {
                return current.*;
            }

            if (current.next == null) {
                break;
            }

            i = i + 1;
            current = current.next.?;
        }

        return Arguments{ .i = 0, .l = 0, .t = 0, .n = 0, .next = null, .prev = null };
    }

    pub fn getOption(self: *LinkedList, l: usize, o: usize) ![]const u8 {
        var argument: Arguments = self.getLink(l);
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const gpaAllocator = gpa.allocator();
        // Executes the given code, or block, on scope exit. "Scope exit" includes reaching the end of the scope or returning from the scope.
        defer _ = gpa.deinit();

        const message = std.heap.page_allocator.dupe(u8, &[1]u8{'\n'}) catch |err| switch (err) {
            error.OutOfMemory => return InitError.OutOfMemory,
        };

        if (std.process.argsAlloc(gpaAllocator)) |args| {
            defer std.process.argsFree(gpaAllocator, args);

            var i: usize = 0;
            var j: usize = 0;
            var flag: bool = false;
            for (args) |arg| {
                if (flag == true) {
                    j = j + 1;
                    if (j < argument.getArgc()) {
                        //std.debug.print(" {s} ", .{arg});

                        if (j == o) {
                            //return message;
                            //break;
                            return try std.heap.page_allocator.dupe(u8, arg);
                        }
                    } else {
                        j = 0;
                        flag = false;

                        //std.debug.print("\n", .{});
                    }
                }

                if (argument.getIndex() == i) {
                    //std.debug.print("Found {} -> {s} and n = {} -> ", .{ argument.getIndex(), arg, argument.getArgc() });

                    flag = true;
                }

                i = i + 1;
            }
        } else |_| {
            return InitError.OutOfMemory;
        }
        //defer std.process.argsFree(gpaAllocator, args);

        //var i: usize = 0;
        //var j: usize = 0;
        //var flag: bool = false;
        //for (args) |arg| {
        //std.debug.print("{s} - ", .{arg});

        //    if (flag == true) {
        //        j = j + 1;
        //        if (j < argument.getArgc()) {
        //std.debug.print(" {s} ", .{arg});

        //            if (j == o) {
        //return message;
        //break;
        //                return try std.heap.page_allocator.dupe(u8, arg);
        //            }
        //        } else {
        //            j = 0;
        //            flag = false;

        //std.debug.print("\n", .{});
        //        }
        //    }

        //    if (argument.getIndex() == i) {
        //std.debug.print("Found {} -> {s} and n = {} -> ", .{ argument.getIndex(), arg, argument.getArgc() });

        //        flag = true;
        //    }

        //    i = i + 1;
        //}

        return message;
    }

    pub fn next(self: *LinkedList) bool {
        if (self.currentLinkNumber < self.size()) {
            self.currentLinkNumber = self.currentLinkNumber + 1;

            return true;
        }

        self.currentLinkNumber = 0;

        return false;
    }

    pub fn nextOption(self: *LinkedList) bool {
        if (self.currentOptionNumber < self.getArgArgc()) {
            self.currentOptionNumber = self.currentOptionNumber + 1;

            return true;
        }

        self.currentOptionNumber = 0;

        return false;
    }

    pub fn nextCommonOption(self: *LinkedList) bool {
        var argument: Arguments = self.getLink(1);

        if (argument.getIndex() > 1) {
            if (self.currentCommonOptionNumber < argument.getIndex()) {
                self.currentCommonOptionNumber = self.currentCommonOptionNumber + 1;

                return true;
            }
        }

        //std.debug.print(" Hello World {} \n", .{argument.getIndex()});

        //std.debug.print("---------> {}", .{argument.getArgIndex()});

        self.currentCommonOptionNumber = 1;
        return false;
    }

    pub fn size(self: *LinkedList) usize {
        return self.getLength();
    }

    // Only optionals can compare to null.
    pub fn traverse(self: *LinkedList) void {
        if (self.arguments == null) {
            return;
        }

        var current: *Arguments = self.arguments.?;

        while (true) {
            std.debug.print("i = {}, l = {}, t = {}, n = {}\n", .{ current.i, current.l, current.t, current.n });

            if (current.next == null) {
                break;
            }

            current = current.next.?;
        }
    }
};
