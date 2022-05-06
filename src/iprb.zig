// Count dna in a string

const std = @import("std");
const data = @embedFile("../input/iprb.txt");

const Population = struct {
    hom_dom: usize = 0,
    het: usize = 0,
    hom_rec: usize = 0,

    const Self = @This();

    fn dom_allele_prob(self: Self) f64 {
        const a = @intToFloat(f64, self.hom_dom);
        const b = @intToFloat(f64, self.het);
        const c = @intToFloat(f64, self.hom_rec);
        const t = a + b + c;

        // (prb of dominant allele in pairing)
        // * (choose first of pair)
        // * (choose second of pair)
        // { * 2 if order matters } (i.e. pair is of different genotypes)
        const part1 = 1.0 * (a / t) * (a - 1.0) / (t - 1.0);
        const part2 = 1.0 * (a / t) * b / (t - 1.0) * 2.0;
        const part3 = 1.0 * (a / t) * c / (t - 1.0) * 2.0;
        const part4 = 0.75 * (b / t) * (b - 1.0) / (t - 1.0);
        const part5 = 0.5 * (b / t) * c / (t - 1.0) * 2.0;

        return part1 + part2 + part3 + part4 + part5;
    }
};

pub fn main() anyerror!void {
    var pop = Population{};

    var tokens = std.mem.tokenize(u8, data, " \r\n");
    pop.hom_dom = try std.fmt.parseInt(usize, tokens.next().?, 10);
    pop.het = try std.fmt.parseInt(usize, tokens.next().?, 10);
    pop.hom_rec = try std.fmt.parseInt(usize, tokens.next().?, 10);

    std.debug.print("{d}", .{pop.dom_allele_prob()});
}
