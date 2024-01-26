// src/arguments.zig
// Q@khaa.pk

const std = @import("std");

pub const Arguments = struct {
    const Self = @This();

    i: usize, // Index number
    l: usize, // Line number
    t: usize, // Token number
    n: usize, // argc

    next: ?*Arguments,
    prev: ?*Arguments,

    // Get m, argument count
    pub fn getArgc(self: *Self) usize {
        return self.n;
    }

    // Index number
    pub fn getIndex(self: *Self) usize {
        return self.i;
    }

    // Line number
    pub fn getLine(self: *Self) usize {
        return self.l;
    }

    // Token number
    pub fn getToken(self: *Self) usize {
        return self.t;
    }

    // Set argument count
    pub fn setArgc(self: *Self, n: usize) void {
        self.n = n;
    }
};
