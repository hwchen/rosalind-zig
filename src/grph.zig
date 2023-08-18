const std = @import("std");
const parse_fasta = @import("parse_fasta.zig");
const FastaCollection = parse_fasta.FastaCollection;
const data = @embedFile("./input/grph.txt");

pub fn main() !void {
    var fasta_collection = FastaCollection.from_str(data);
    while (try fasta_collection.next()) |*fasta| {
        std.debug.print("processing: {s}\n", .{fasta.label});
    }
}
