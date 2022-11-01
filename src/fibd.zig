// fibonacci w/ death after m months
//
// n is nubmer of generations
// m is rabbit lifespan
// a pair of rabbits produces a pair of offspring each month
//
// m is <= 20, so just put the array on the stack.
//
// This is a bit finicky, and I had to look up help online. Easy to get off-by-one in
// several places.

const std = @import("std");
const data = @embedFile("../input/fibd.txt");

pub fn main() anyerror!void {
    const init = comptime blk: {
        var tokens = std.mem.tokenize(u8, data, " \r\n");
        const n = try std.fmt.parseInt(u64, tokens.next().?, 10);
        const m = try std.fmt.parseInt(u64, tokens.next().?, 10);
        break :blk .{ n, m };
    };
    const n = init.@"0";
    const m = init.@"1";
    std.debug.print("n = {}, m = {}\n", .{ n, m });

    // generation count is arbitrary, based on what the problem gives
    var gen: u64 = 1;
    // tag on 001 at end to guarantee there's enough slots to calculate recurrence
    var state = comptime [_]u64{0} ** m ++ [_]u64{ 0, 0, 1 };
    var total_idx: usize = m + 2;
    var d_idx: usize = 1;

    while (gen < n) : (gen += 1) {
        std.mem.rotate(u64, &state, 1);
        if (gen == m) {
            // have to check closer as to why this one differs. There's an off-by-one
            // for the starting condition?
            state[total_idx] = state[total_idx - 2] + state[total_idx - 1] - 1;
        } else {
            state[total_idx] = state[total_idx - 2] + state[total_idx - 1] - state[d_idx];
        }
        //std.debug.print("{any}, {}, {}, {}\n", .{ state, state[total_idx - 2], state[total_idx - 1], state[d_idx] });
    }
    std.debug.print("{}", .{state[total_idx]});
}
