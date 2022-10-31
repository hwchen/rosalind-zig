const std = @import("std");
const mem = std.mem;
const containsAtLeast = std.mem.containsAtLeast;
const assert = std.debug.assert;

pub const FastaCollection = struct {
    slice: []const u8,
    idx: usize = 0,

    pub const Self = FastaCollection;

    pub fn from_str(input: []const u8) Self {
        return Self{
            .slice = input,
            .idx = mem.indexOf(u8, input, ">") orelse 0,
        };
    }

    pub fn next(self: *Self) !?Fasta {
        if (self.idx >= self.slice.len) {
            return null;
        }
        // this check not necessary if we do streaming state machine
        // but it enables shifting frame of reference w/ idx + 1 below
        if (self.slice.len - self.idx <= 1) {
            return error.IncompleteInput;
        }

        // shift frame of reference for searching for end, since we want to search for the second '>' as the end.
        const end = if (mem.indexOf(u8, self.slice[self.idx + 1 ..], ">")) |i| self.idx + i + 1 else self.slice.len;
        const fasta_slice = self.slice[self.idx..end];
        self.idx = end;
        return parse_one_fasta(fasta_slice) catch |err| err;
    }
};

// Input: one fasta record
// Output: the Sequence of that record, as an iterator
pub fn parse_one_fasta(input: []const u8) !Fasta {
    if (input.len <= 1) {
        return error.IncompleteInput;
    }
    if (input[0] != '>') {
        return error.IncorrectInitialCharacter;
    }

    const label_end = mem.indexOf(u8, input, "\n") orelse return error.NoSequenceOnlyLabel;
    return Fasta{
        .label = input[1..label_end],
        .sequence = Sequence{ .slice = input[label_end + 1 ..] },
    };
}

// refers to slice of source, so must not outlive the source
pub const Fasta = struct {
    label: []const u8,
    sequence: Sequence,
};

pub const Sequence = struct {
    slice: []const u8,
    idx: usize = 0,

    const ApprovedChars = [_]u8{ 'A', 'C', 'G', 'T' };

    // skips over whitespace
    pub fn next(self: *Sequence) ?u8 {
        // fast-forward through whitespace before checking to return null
        while (self.idx < self.slice.len and !self.curr_is_approved_char()) {
            self.idx += 1;
        }

        if (self.idx >= self.slice.len) {
            return null;
        }

        const res = self.slice[self.idx];
        self.idx += 1;
        return res;
    }

    // will panic if self.idx out of bounds
    fn curr_is_approved_char(self: Sequence) bool {
        return containsAtLeast(u8, &ApprovedChars, 1, self.slice[self.idx .. self.idx + 1]);
    }

    pub fn count(self: Sequence) u64 {
        var this = Sequence{
            .slice = self.slice,
            .idx = 0,
        };
        var total: u64 = 0;
        while (this.next()) |_| {
            total += 1;
        }
        return total;
    }
};

test "parse empty" {
    const input = "";
    try std.testing.expectError(error.IncompleteInput, parse_one_fasta(input));
}

test "parse too short" {
    const input = ">";
    try std.testing.expectError(error.IncompleteInput, parse_one_fasta(input));
}

test "parse wrong initial character" {
    const input = "<test fasta\nA";
    try std.testing.expectError(error.IncorrectInitialCharacter, parse_one_fasta(input));
}

test "parse one fasta" {
    const input = ">Rosalind_1\nATCCAGCT";
    const output = try parse_one_fasta(input);
    try std.testing.expectEqualStrings("Rosalind_1", output.label);
    try std.testing.expectEqualStrings("ATCCAGCT", output.sequence.slice);
}

test "parse one fasta; iterate sequence w whitespace" {
    const input = ">Rosalind_1\nA\nT\n";
    const output = try parse_one_fasta(input);
    try std.testing.expectEqualStrings(output.label, "Rosalind_1");
    try std.testing.expectEqualStrings(output.sequence.slice, "A\nT\n");

    var seq = output.sequence;
    try std.testing.expectEqual(seq.next().?, 'A');
    try std.testing.expectEqual(seq.next().?, 'T');
    try std.testing.expectEqual(seq.next(), null);
}
