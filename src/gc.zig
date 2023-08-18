// gc

const std = @import("std");
const ArrayList = std.ArrayList;
const data = @embedFile("./input/gc.txt");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var chunks = std.mem.tokenize(u8, data, ">");

    const dna_strings = blk: {
        var res = ArrayList(DnaString).init(alloc);
        while (chunks.next()) |chunk| {
            try res.append(try parseFasta(chunk));
        }
        break :blk res;
    };

    var max_gc = dna_strings.items[0];
    for (dna_strings.items) |dna_string| {
        if (dna_string.gc() > max_gc.gc()) {
            max_gc = dna_string;
        }
    }
    std.debug.print("{s}\n{d}", .{ max_gc.name, max_gc.gc() });
}

const DnaString = struct {
    name: []const u8,
    dna: []const u8,

    fn gc(self: DnaString) f32 {
        var gc_count: u32 = 0;
        var total: u32 = 0; // to take \r \n into account in string
        for (self.dna) |c| {
            switch (c) {
                'G', 'C' => {
                    gc_count += 1;
                    total += 1;
                },
                'A', 'T' => {
                    total += 1;
                },
                else => {},
            }
        }

        return 100 * @as(f32, @floatFromInt(gc_count)) / @as(f32, @floatFromInt(total));
    }
};

fn parseFasta(s: []const u8) !DnaString {
    const split_idx = std.mem.indexOf(u8, s, "\n") orelse return error.incorrectFastaFormat;
    return DnaString{
        .name = s[0..split_idx],
        .dna = s[split_idx + 1 ..],
    };
}
