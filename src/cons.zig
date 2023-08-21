// Consensus and profile

const std = @import("std");
const mem = std.mem;
const parse_fasta = @import("parse_fasta.zig");
const data = @embedFile("./input/cons.txt");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var consensus = comptime blk: {
        @setEvalBranchQuota(10000);
        var seq_len = try parse_fasta.parseOneFastaSeqLength(data);
        break :blk Consensus(seq_len){};
    };

    const fasta_collection = try parse_fasta.parseFastaCollectionDna(data, alloc);
    for (fasta_collection) |fasta| {
        std.debug.print("processing: {s}\n", .{fasta.label});
        var seq_idx: usize = 0;
        for (fasta.seq) |n| {
            switch (n) {
                .A => consensus.a[seq_idx] += 1,
                .C => consensus.c[seq_idx] += 1,
                .G => consensus.g[seq_idx] += 1,
                .T => consensus.t[seq_idx] += 1,
            }
            seq_idx += 1;
        }
    }

    try consensus.printConsensusString();
}

fn Consensus(comptime N: comptime_int) type {
    // u8 because there's only up to 10 strings of at most 1kbp
    // TODO can this use multiarray?
    return struct {
        a: [N]u8 = undefined,
        c: [N]u8 = undefined,
        g: [N]u8 = undefined,
        t: [N]u8 = undefined,

        const Self = @This();

        pub fn printConsensusString(self: Self) !void {
            const stdout = std.io.getStdOut().writer();
            var buf_stdout = std.io.bufferedWriter(stdout);
            const wtr = buf_stdout.writer();

            var acgt: [4]u8 = undefined;
            var i: usize = 0;
            while (i < N) : (i += 1) {
                acgt[0] = self.a[i];
                acgt[1] = self.c[i];
                acgt[2] = self.g[i];
                acgt[3] = self.t[i];

                const acgt_idx = indexOfMax(&acgt);
                if (acgt_idx == 0) {
                    _ = try wtr.write("A");
                } else if (acgt_idx == 1) {
                    _ = try wtr.write("C");
                } else if (acgt_idx == 2) {
                    _ = try wtr.write("G");
                } else if (acgt_idx == 3) {
                    _ = try wtr.write("T");
                }
            }
            try buf_stdout.flush();
        }
    };
}

fn indexOfMax(xs: []u8) usize {
    var res: usize = 0;
    var max: u8 = 0;
    for (xs, 0..) |x, i| {
        if (x > max) {
            res = i;
            max = x;
        }
    }

    return res;
}
