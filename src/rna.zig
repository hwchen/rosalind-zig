// Transcribe dna to rna

const std = @import("std");
const data = @embedFile("../input/rna.txt");

pub fn main() anyerror!void {
    for (data) |c| {
        switch (c) {
            'A' => std.debug.print("{c}", .{'A'}),
            'C' => std.debug.print("{c}", .{'C'}),
            'G' => std.debug.print("{c}", .{'G'}),
            'T' => std.debug.print("{c}", .{'U'}),
            else => {},
        }
    }
}
