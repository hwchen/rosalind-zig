const std = @import("std");
const parse_fasta = @import("parse_fasta.zig");
const data = @embedFile("./input/grph.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var fasta_collection = try parse_fasta.parseFastaCollectionDna(data, alloc);
    for (fasta_collection) |fasta| {
        std.debug.print("processing: {s}\n", .{fasta.label});
    }
}
