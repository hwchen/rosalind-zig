const std = @import("std");
const Allocator = std.mem.Allocator;
const fasta = @import("fasta.zig");
const Nuc = fasta.Nuc;
const StringHashMap = std.StringHashMap;
const data = @embedFile("./input/lcsm.txt");

const StringSet = StringHashMap(void);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var collection = try fasta.parseCollectionDna(data, alloc);

    var global_substring_set = try substringSetGenerate(collection[0].seq, alloc);
    for (collection[1..]) |record| {
        const local_substring_set = try substringSetGenerate(record.seq, alloc);
        global_substring_set = try substringSetIntersect(global_substring_set, local_substring_set, alloc);
    }

    var output: []const Nuc = undefined;
    var max_seq_len: usize = 0;
    var iter = global_substring_set.keyIterator();
    while (iter.next()) |key| {
        const ss = keyToSeq(key.*);
        if (ss.len > max_seq_len) {
            output = ss;
            max_seq_len = ss.len;
        }
    }

    for (output) |n| {
        switch (n) {
            Nuc.A => std.debug.print("A", .{}),
            Nuc.C => std.debug.print("C", .{}),
            Nuc.G => std.debug.print("G", .{}),
            Nuc.T => std.debug.print("T", .{}),
        }
    }
    std.debug.print("\n", .{});
}

fn substringSetGenerate(seq: []const Nuc, alloc: Allocator) !StringSet {
    var out = StringSet.init(alloc);
    for (2..seq.len + 1) |ss_len| {
        for (0..seq.len - ss_len + 1) |i| {
            const key = seqToKey(seq[i..][0..ss_len]);
            try out.put(key, {});
        }
    }
    return out;
}

fn substringSetIntersect(set1: StringSet, set2: StringSet, alloc: Allocator) !StringSet {
    var out = StringSet.init(alloc);
    var iter = set1.keyIterator();
    while (iter.next()) |key| {
        if (set2.contains(key.*)) {
            try out.put(key.*, {});
        }
    }

    return out;
}
fn seqToKey(seq: []const Nuc) []const u8 {
    return @ptrCast(seq);
}

fn keyToSeq(key: []const u8) []const Nuc {
    return @ptrCast(key);
}
