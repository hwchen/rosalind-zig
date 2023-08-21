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
    const optimize = b.standardOptimizeOption(.{});

    const problems = [_][]const u8{
        "ini",
        "dna",
        "rna",
        "revc",
        "fib",
        "gc",
        "iprb",
        "prot",
        "subs",
        "cons",
        "fibd",
        "grph",
        "lcsm",
    };

    inline for (problems) |problem| {
        const exe = b.addExecutable(.{
            .name = problem,
            .root_source_file = .{ .path = "src/" ++ problem ++ ".zig" },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(problem, "Run" ++ problem);
        run_step.dependOn(&run_cmd.step);
    }
}
