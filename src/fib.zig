// fibonacci
//
// k is litter size
// n is generations

const std = @import("std");
const data = @embedFile("../input/fib.txt");

pub fn main() anyerror!void {
    var tokens = std.mem.tokenize(u8, data, " \r\n");
    const n = try std.fmt.parseInt(u64, tokens.next().?, 10);
    const k_str = tokens.next().?;
    const k = try std.fmt.parseInt(u64, k_str, 10);

    // generation count is arbitrary, based on what the problem gives
    var gen: u64 = 1;
    var state = [_]u64{ 0, 0, 1 };

    while (gen < n) {
        state[0] = state[1];
        state[1] = state[2];
        // rabbits take a month to mature, so litter size is multiplied by 2 months ago.
        state[2] = (k * state[0]) + state[1];

        gen += 1;
    }
    std.debug.print("{}", .{state[2]});
}
