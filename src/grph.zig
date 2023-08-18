const std = @import("std");
const util = @import("util.zig");
const FastaCollection = util.FastaCollection;
const data = @embedFile("./input/grph.txt");

pub fn main() !void {
    var fasta_collection = FastaCollection.from_str(data);
    while (try fasta_collection.next()) |*fasta| {
        std.debug.print("processing: {s}\n", .{fasta.label});
    }
}
