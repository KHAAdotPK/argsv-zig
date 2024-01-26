// src/linkedlist.zig
// Q@khaa.pk

const std = @import("std");
const Arguments = @import("arguments.zig").Arguments;

pub const LinkedList = struct {
    arguments: ?*Arguments,
    allocator: ?*std.mem.Allocator,
    length: usize, // Number of links

    pub fn add(self: *LinkedList, i: usize, l: usize, t: usize, n: usize) !void {
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

    pub fn find(self: *LinkedList, l: usize) !*Arguments {
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

    pub fn getLength(self: *LinkedList) usize {
        return self.length;
    }

    pub fn size(self: *LinkedList) usize {
        return self.length;
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
