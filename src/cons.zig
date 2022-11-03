// Consensus and profile

const std = @import("std");
const mem = std.mem;
const util = @import("./util.zig");
const FastaCollection = util.FastaCollection;
const data = @embedFile("../input/cons.txt");

pub fn main() anyerror!void {
    var consensus = comptime blk: {
        @setEvalBranchQuota(100000);
        var fasta_collection_prime = FastaCollection.from_str(data);
        const fasta_prime = (try fasta_collection_prime.next()) orelse return error.NoFasta;
        const seq_len = fasta_prime.seq_len();

        break :blk Consensus(seq_len){};
    };

    var fasta_collection = FastaCollection.from_str(data);
    while (try fasta_collection.next()) |*fasta| {
        std.debug.print("processing: {s}\n", .{fasta.label});
        var seq = fasta.sequence();
        var seq_idx: usize = 0;
        while (seq.next()) |n| {
            switch (n) {
                'A' => consensus.a[seq_idx] += 1,
                'C' => consensus.c[seq_idx] += 1,
                'G' => consensus.g[seq_idx] += 1,
                'T' => consensus.t[seq_idx] += 1,
                else => unreachable,
            }
            seq_idx += 1;
        }
    }

    consensus.printConsensusString();
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

        pub fn printConsensusString(self: Self) void {
            var acgt: [4]u8 = undefined;
            var i: usize = 0;
            while (i < N) : (i += 1) {
                acgt[0] = self.a[i];
                acgt[1] = self.c[i];
                acgt[2] = self.g[i];
                acgt[3] = self.t[i];

                const acgt_idx = indexOfMax(&acgt);
                if (acgt_idx == 0) {
                    std.debug.print("A", .{});
                } else if (acgt_idx == 1) {
                    std.debug.print("C", .{});
                } else if (acgt_idx == 2) {
                    std.debug.print("G", .{});
                } else if (acgt_idx == 3) {
                    std.debug.print("T", .{});
                }
            }
        }
    };
}

fn indexOfMax(xs: []u8) usize {
    var res: usize = 0;
    var max: u8 = 0;
    for (xs) |x, i| {
        if (x > max) {
            res = i;
            max = x;
        }
    }

    return res;
}
