// Translating RNA into protein

const std = @import("std");
const data = @embedFile("./input/prot.txt");

pub fn main() anyerror!void {
    var i: usize = 0;
    while (i < data.len) : (i += 3) {
        const codon = data[i .. i + 3]; // for now don't worry about incorrect codons
        const codon_res = try translate_codon(codon);
        switch (codon_res) {
            .amino_acid => |a| {
                std.debug.print("{c}", .{a});
            },
            .stop => break,
        }
    }
}

fn translate_codon(codon: []const u8) !CodonResult {
    if (codon.len != 3) {
        return error.InvalidCodonLength;
    }

    if (translation_table.get(codon)) |res| {
        return res;
    } else {
        return error.CodonNotFound;
    }
}

const CodonResult = union(enum) {
    amino_acid: u8,
    stop,
};

// ComptimeStringMap is not optimized for this usecase; could create a custom
// comptime hash map in future.
const translation_table = std.ComptimeStringMap(CodonResult, .{
    .{ "UUU", .{ .amino_acid = 'F' } },
    .{ "UUC", .{ .amino_acid = 'F' } },
    .{ "UUA", .{ .amino_acid = 'L' } },
    .{ "UUG", .{ .amino_acid = 'L' } },
    .{ "UCU", .{ .amino_acid = 'S' } },
    .{ "UCC", .{ .amino_acid = 'S' } },
    .{ "UCA", .{ .amino_acid = 'S' } },
    .{ "UCG", .{ .amino_acid = 'S' } },
    .{ "UAU", .{ .amino_acid = 'Y' } },
    .{ "UAC", .{ .amino_acid = 'Y' } },
    .{ "UAA", .stop },
    .{ "UAG", .stop },
    .{ "UGU", .{ .amino_acid = 'C' } },
    .{ "UGC", .{ .amino_acid = 'C' } },
    .{ "UGA", .stop },
    .{ "UGG", .{ .amino_acid = 'W' } },

    .{ "CUU", .{ .amino_acid = 'L' } },
    .{ "CUC", .{ .amino_acid = 'L' } },
    .{ "CUA", .{ .amino_acid = 'L' } },
    .{ "CUG", .{ .amino_acid = 'L' } },
    .{ "CCU", .{ .amino_acid = 'P' } },
    .{ "CCC", .{ .amino_acid = 'P' } },
    .{ "CCA", .{ .amino_acid = 'P' } },
    .{ "CCG", .{ .amino_acid = 'P' } },
    .{ "CAU", .{ .amino_acid = 'H' } },
    .{ "CAC", .{ .amino_acid = 'H' } },
    .{ "CAA", .{ .amino_acid = 'Q' } },
    .{ "CAG", .{ .amino_acid = 'Q' } },
    .{ "CGU", .{ .amino_acid = 'R' } },
    .{ "CGC", .{ .amino_acid = 'R' } },
    .{ "CGA", .{ .amino_acid = 'R' } },
    .{ "CGG", .{ .amino_acid = 'R' } },

    .{ "AUU", .{ .amino_acid = 'I' } },
    .{ "AUC", .{ .amino_acid = 'I' } },
    .{ "AUA", .{ .amino_acid = 'I' } },
    .{ "AUG", .{ .amino_acid = 'M' } },
    .{ "ACU", .{ .amino_acid = 'T' } },
    .{ "ACC", .{ .amino_acid = 'T' } },
    .{ "ACA", .{ .amino_acid = 'T' } },
    .{ "ACG", .{ .amino_acid = 'T' } },
    .{ "AAU", .{ .amino_acid = 'N' } },
    .{ "AAC", .{ .amino_acid = 'N' } },
    .{ "AAA", .{ .amino_acid = 'K' } },
    .{ "AAG", .{ .amino_acid = 'K' } },
    .{ "AGU", .{ .amino_acid = 'S' } },
    .{ "AGC", .{ .amino_acid = 'S' } },
    .{ "AGA", .{ .amino_acid = 'R' } },
    .{ "AGG", .{ .amino_acid = 'R' } },

    .{ "GUU", .{ .amino_acid = 'V' } },
    .{ "GUC", .{ .amino_acid = 'V' } },
    .{ "GUA", .{ .amino_acid = 'V' } },
    .{ "GUG", .{ .amino_acid = 'V' } },
    .{ "GCU", .{ .amino_acid = 'A' } },
    .{ "GCC", .{ .amino_acid = 'A' } },
    .{ "GCA", .{ .amino_acid = 'A' } },
    .{ "GCG", .{ .amino_acid = 'A' } },
    .{ "GAU", .{ .amino_acid = 'D' } },
    .{ "GAC", .{ .amino_acid = 'D' } },
    .{ "GAA", .{ .amino_acid = 'E' } },
    .{ "GAG", .{ .amino_acid = 'E' } },
    .{ "GGU", .{ .amino_acid = 'G' } },
    .{ "GGC", .{ .amino_acid = 'G' } },
    .{ "GGA", .{ .amino_acid = 'G' } },
    .{ "GGG", .{ .amino_acid = 'G' } },
});
