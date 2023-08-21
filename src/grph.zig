const std = @import("std");
const fasta = @import("fasta.zig");
const Nuc = fasta.Nuc;
const data = @embedFile("./input/grph.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var collection = try fasta.parseCollectionDna(data, alloc);
    for (collection) |r1| {
        for (collection) |r2| {
            if (std.mem.eql(u8, r1.label, r2.label)) continue;
            //std.debug.print("processing: {s}\n", .{record.label});

            if (seqsAreOverlap(3, r1.seq, r2.seq)) {
                std.debug.print("{s}, {s}\n", .{ r1.label, r2.label });
            }
        }
    }
}

// checks if tail of seq1 overlaps with head of seq2
fn seqsAreOverlap(k: usize, seq1: []const Nuc, seq2: []const Nuc) bool {
    return std.mem.eql(Nuc, seq1[seq1.len - k ..], seq2[0..k]);
}
