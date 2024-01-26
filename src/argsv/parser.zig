// src/parer.zig
// Q@khaa.pk

const std = @import("std");

///*
//    const commands = "h,-h,(Displays the help screen)\nv,-v,verbose,(Does the detailed output)\n";
//    const commands = "h,-h(Displays the help screen\nv,-v,verbose(Does the detailed output";
//
//    Optional Parts Explanation:
//    Both constants represent the same set of commands, but with different formatting.
//    The first constant includes newline characters ('\n'), commas (',') and
//    closing parenthesis (')') for readability, while the second constant omits them.
//
//    Importantly, the parsing code associated with these constants is designed to handle
//    these differences. Whether the string is formatted with or without newlines, commas
//    and closing parenthesis, the parsing logic is robust enough to correctly interpret and
//    process the command list. This flexibility ensures that the parsing code is versatile
//    and accommodates variations in the string representation of commands.
//*/

const END_OF_LINE_MARKER: u8 = '\n';
const END_OF_TOKEN_MARKER: u8 = ',';
const START_OF_HELP_TEXT_MARKER: u8 = '(';
const END_OF_HELP_TEXT_MARKER: u8 = ')';

pub const Parser = struct {
    currentLineNumber: usize,
    currentTokenNumber: usize,

    // Common operations
    pub fn getLength(_: *Parser, commands: []const u8) usize {
        var length: usize = 0;

        for (commands) |_| {
            length = length + 1;
        }

        return length;
    }

    // Line operations
    pub fn getTotalNumberOfLines(self: *Parser, commands: []const u8) usize {
        var i: usize = 0;
        var j: usize = 0;
        var n: usize = 0;

        if (getLength(self, commands) > 0) {
            for (commands) |byte| {
                if (byte == END_OF_LINE_MARKER) {
                    n = n + 1;
                    j = i + 1;
                }

                i = i + 1;
            }

            if (j < getLength(self, commands)) {
                n = n + 1;
            }
        }

        return n;
    }

    pub fn getLineByNumber(self: *Parser, commands: []const u8, n: usize) []const u8 {
        var i: usize = 0;
        var length: usize = 0;
        var offset: usize = 0;

        if (n > 0) {
            if (n <= getTotalNumberOfLines(self, commands)) {
                for (commands) |byte| {
                    length = length + 1;
                    if (byte == END_OF_LINE_MARKER) {
                        i = i + 1;

                        if (i == n) {
                            return commands[offset..(offset + length)];
                        }

                        offset = offset + length;

                        length = 0;
                    }
                }

                if (n == getTotalNumberOfLines(self, commands)) {
                    return commands[offset..(offset + length)];
                }
            }
        }

        // If the requested line number is out of bounds, return an empty slice
        return commands[0..0];
    }

    pub fn goToNextLine(self: *Parser, commands: []const u8) []const u8 {
        if (self.currentLineNumber < getTotalNumberOfLines(self, commands)) {
            self.currentLineNumber = self.currentLineNumber + 1;

            return getLineByNumber(self, commands, self.currentLineNumber);
        }

        self.currentLineNumber = 0;

        return commands[0..0];
    }

    // Token operations
    pub fn goToNextToken(self: *Parser, line: []const u8) []const u8 {
        if (self.currentTokenNumber < getTotalNumberOfTokens(self, line)) {
            self.currentTokenNumber = self.currentTokenNumber + 1;
            return getTokenByNumber(self, line, self.currentTokenNumber);
        }

        self.currentTokenNumber = 0;

        return line[0..0];
    }

    pub fn getTokenByNumber(self: *Parser, line: []const u8, n: usize) []const u8 {
        var i: usize = 0;
        var length: usize = 0;
        var offset: usize = 0;

        if (n > 0) {
            if (n <= getTotalNumberOfTokens(self, line)) {
                for (line) |byte| {
                    length = length + 1;
                    if (byte == END_OF_TOKEN_MARKER) {
                        i = i + 1;

                        if (i == n) {
                            return line[offset..(offset + (length - 1))];
                        }

                        offset = offset + length;

                        length = 0;
                    }
                    if (byte == START_OF_HELP_TEXT_MARKER) {
                        if (n == getTotalNumberOfTokens(self, line)) {
                            return line[offset..(offset + (length - 1))];
                        }
                    }
                }
            }
        }

        // If the requested line number is out of bounds, return an empty slice
        return line[0..0];
    }

    pub fn getTotalNumberOfTokens(self: *Parser, line: []const u8) usize {
        var i: usize = 0;
        var j: usize = 0;
        var n: usize = 0;

        if (getLength(self, line) > 0) {
            for (line) |byte| {
                if (byte == END_OF_TOKEN_MARKER) {
                    n = n + 1;
                    j = i + 1;
                } else if (byte == START_OF_HELP_TEXT_MARKER) {
                    if ((i - j) > 1) {
                        n = n + 1;
                        break;
                    }
                }

                i = i + 1;
            }
        }

        return n;
    }

    // Help text operations
    pub fn getHelpText(self: *Parser, line: []const u8) []const u8 {
        var i: usize = 0;
        var j: usize = 0;
        var k: usize = 0;

        if (getLength(self, line) > 0) {
            for (line) |byte| {
                if (byte == START_OF_HELP_TEXT_MARKER) {
                    j = i + 1;
                }

                if (byte == END_OF_HELP_TEXT_MARKER) {
                    k = i;
                }

                if (j > 0) {
                    if (k > 0) {
                        return line[j..k];
                    }
                }

                i = i + 1;
            }

            if (j > 0) {
                return line[j..];
            }
        }

        return line[0..0];
    }

    // Static method
    pub fn compareSlice(a: []const u8, b: []const u8) bool {
        if (a.len != b.len) {
            return false;
        }

        var i: usize = 0;
        while (i < a.len) : (i += 1) {
            if (a[i] != b[i]) {
                return false;
            }
        }

        return true;
    }
};
