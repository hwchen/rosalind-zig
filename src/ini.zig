const std = @import("std");
const data = @embedFile("../input/ini.txt");

pub fn main() anyerror!void {
    var counts = Counts{};

    for (data) |c| {
        switch (c) {
            'A' => {
                counts.a += 1;
            },
            'C' => {
                counts.c += 1;
            },
            'G' => {
                counts.g += 1;
            },
            'T' => {
                counts.t += 1;
            },
            else => {},
        }
    }

    std.debug.print("{d} {d} {d} {d}\n", .{ counts.a, counts.c, counts.g, counts.t });
}

const Counts = struct {
    a: usize = 0,
    c: usize = 0,
    g: usize = 0,
    t: usize = 0,
};
