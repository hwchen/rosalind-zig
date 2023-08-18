// Find motif in DNA
//
// (Naive exact match)

const std = @import("std");
const data = @embedFile("./input/subs.txt");

pub fn main() anyerror!void {
    var tokens = std.mem.tokenize(u8, data, " \n");
    const t = tokens.next().?;
    // s is maybe substring
    const s = tokens.next().?;

    var i: usize = 0;
    outer: while (i < t.len - s.len) : (i += 1) {
        // at this position, check if s is substring
        var j: usize = 0;
        while (j < s.len) : (j += 1) {
            // for any character mismatch, stop here and continue on w/ outer loop.
            if (t[j + i] != s[j]) continue :outer;
        }
        // print if it is a substring
        std.debug.print("{d} ", .{i + 1});
    }
}
