// to get this to compile for looping over days, needed:
// - const days to be comptime
// - for to be inline (why?)
// - comptimePrint

const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const problems = [_][]const u8{ "ini", "dna", "rna", "revc", "fib", "gc" };

    inline for (problems) |problem| {
        const exe = b.addExecutable(problem, "src/" ++ problem ++ ".zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(problem, "Run" ++ problem);
        run_step.dependOn(&run_cmd.step);
    }
}