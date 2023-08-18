// complement DNA strand

const std = @import("std");
const data = @embedFile("./input/revc.txt");

pub fn main() anyerror!void {
    // reverse iterator and then complement
    var i = data.len;

    while (i > 0) {
        i -= 1;
        switch (data[i]) {
            'A' => std.debug.print("{c}", .{'T'}),
            'C' => std.debug.print("{c}", .{'G'}),
            'G' => std.debug.print("{c}", .{'C'}),
            'T' => std.debug.print("{c}", .{'A'}),
            else => {},
        }
    }
}
