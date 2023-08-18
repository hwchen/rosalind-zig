// Count dna in a string

const std = @import("std");
const data = @embedFile("./input/dna.txt");

const Counts = struct {
    a: u64 = 0,
    c: u64 = 0,
    g: u64 = 0,
    t: u64 = 0,
};

pub fn main() anyerror!void {
    var counts = Counts{};
    for (data) |c| {
        switch (c) {
            'A' => counts.a += 1,
            'C' => counts.c += 1,
            'G' => counts.g += 1,
            'T' => counts.t += 1,
            else => {},
        }
    }

    std.debug.print("{}", .{counts});
}
