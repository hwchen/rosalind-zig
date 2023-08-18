const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const containsAtLeast = std.mem.containsAtLeast;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;

pub const Nuc = enum(u8) {
    A = 0b0001,
    T = 0b0010,
    C = 0b0100,
    G = 0b1000,
};

// caller frees
pub fn parseFastaCollectionDna(input: []const u8, alloc: Allocator) ![]FastaDna {
    var collection = ArrayList(FastaDna).init(alloc);

    var i: u64 = 0;
    var input_tail = input;

    while (true) {
        const fasta_res = try parseOneFastaDna(input_tail, alloc);
        try collection.append(fasta_res.fasta);

        i += fasta_res.bytes_read;
        if (i >= input_tail.len) {
            break;
        }
        input_tail = input_tail[i..];
    }

    return collection.toOwnedSlice();
}

pub const FastaDna = struct {
    label: []u8,
    seq: []Nuc,
};

// Input: one fasta record
// Output: label and sequence, caller must free.
pub fn parseOneFastaDna(input: []const u8, alloc: Allocator) !struct { fasta: FastaDna, bytes_read: u64 } {
    if (input.len <= 1) {
        return error.IncompleteInput;
    }
    if (input[0] != '>') {
        return error.IncorrectInitialCharacter;
    }

    const label_end = mem.indexOf(u8, input, "\n") orelse return error.NoSequenceOnlyLabel;
    const label = try alloc.alloc(u8, label_end - 1);
    @memcpy(label, input[1..label_end]);

    var seq = ArrayList(Nuc).init(alloc);
    var seq_bytes_read: u64 = 0;
    for (input[label_end + 1 ..]) |c| {
        switch (c) {
            'A' => try seq.append(.A),
            'T' => try seq.append(.T),
            'C' => try seq.append(.C),
            'G' => try seq.append(.G),
            '>' => break,
            else => {},
        }
        seq_bytes_read += 1;
    }
    return .{
        .fasta = FastaDna{
            .label = label,
            .seq = try seq.toOwnedSlice(),
        },
        .bytes_read = label_end + seq_bytes_read + 1,
    };
}

test "parse empty" {
    const alloc = std.testing.allocator;
    const input = "";
    try std.testing.expectError(error.IncompleteInput, parseOneFastaDna(input, alloc));
}

test "parse too short" {
    const alloc = std.testing.allocator;
    const input = ">";
    try std.testing.expectError(error.IncompleteInput, parseOneFastaDna(input, alloc));
}

test "parse wrong initial character" {
    const alloc = std.testing.allocator;
    const input = "<test fasta\nA";
    try std.testing.expectError(error.IncorrectInitialCharacter, parseOneFastaDna(input, alloc));
}

test "parse one fasta" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    {
        const input = ">Rosalind_1\nATCCAGCT";
        const output = try parseOneFastaDna(input, alloc);
        try std.testing.expectEqualStrings("Rosalind_1", output.fasta.label);
        try std.testing.expectEqualSlices(Nuc, &[_]Nuc{ .A, .T, .C, .C, .A, .G, .C, .T }, output.fasta.seq);
    }

    {
        const input = ">Rosalind_1\nA\nT\n";
        const output = try parseOneFastaDna(input, alloc);
        try std.testing.expectEqualStrings("Rosalind_1", output.fasta.label);
        try std.testing.expectEqualSlices(Nuc, &[_]Nuc{ .A, .T }, output.fasta.seq);
    }
}

test "parse fasta collection" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const input = ">Rosalind_1\nATCCAGCT\n>Rosalind_2\nA\nT\n";
    const collection = try parseFastaCollectionDna(input, alloc);

    try std.testing.expectEqualStrings("Rosalind_1", collection[0].label);
    try std.testing.expectEqualSlices(Nuc, &[_]Nuc{ .A, .T, .C, .C, .A, .G, .C, .T }, collection[0].seq);

    try std.testing.expectEqualStrings("Rosalind_2", collection[1].label);
    try std.testing.expectEqualSlices(Nuc, &[_]Nuc{ .A, .T }, collection[1].seq);
}
